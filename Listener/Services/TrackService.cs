﻿using Listener.Models.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Listener.Services
{
    public class TrackService : ITrackService
    {
        private readonly string _storagePath;
        private readonly IRabbitMqService _rabbitMqService;
        private const int _bufferSize = 1024 * 1024;

        public TrackService(IRabbitMqService rabbitMqService)
        {
            _storagePath = Path.Combine(Path.GetTempPath(), "musewave_tracks");
            _rabbitMqService = rabbitMqService;
        }

        public async Task StoreTrack(TrackUploadDto model)
        {
            try
            {
                // Ensure the storage directory exists
                var userDirectoryPath = Path.Combine(_storagePath, model.artistId);
                if (!Directory.Exists(userDirectoryPath))
                {
                    Directory.CreateDirectory(userDirectoryPath);
                }

                // Generate a unique file name with the current date appended
                var fileName = $"{Guid.NewGuid()}_{DateTime.Now.ToString("yyyyMMddHHmmss")}{Path.GetExtension(model.mediaFile.FileName)}";

                // Save the file to the user's directory
                var filePath = Path.Combine(userDirectoryPath, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await model.mediaFile.CopyToAsync(stream);
                }

                // Send the file name to the RabbitMQ service
                _rabbitMqService.SendMessage(new RabbitMqMessage
                {
                    Payload = fileName,
                    ArtistId = model.artistId,
                    TrackId = model.trackId
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                throw new Exception("An error occurred while processing the track", ex);
            }
        }

        public async Task<FileStreamResult> HandleTrackStreamRequest(string trackId, string artistId, string range)
        {
            var userDirectoryPath = Path.Combine(_storagePath, artistId);
            var filePath = Path.Combine(userDirectoryPath, trackId);

            if (!System.IO.File.Exists(filePath))
            {
                throw new FileNotFoundException("The requested file was not found");
            }

            var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var contentType = GetContentType(filePath);
            var fileLength = fileStream.Length;
            //var range = Request.Headers["Range"].ToString();

            if (!string.IsNullOrEmpty(range))
            {
                var rangeStart = long.Parse(range.Replace("bytes=", "").Split('-')[0]);
                var rangeEnd = rangeStart + _bufferSize;

                if (rangeEnd > fileLength)
                {
                    rangeEnd = fileLength;
                }

                var lengthToRead = rangeEnd - rangeStart;
                var buffer = new byte[lengthToRead];
                fileStream.Seek(rangeStart, SeekOrigin.Begin);
                await fileStream.ReadAsync(buffer, 0, (int)lengthToRead);

                return new FileStreamResult(new MemoryStream(buffer), contentType)
                {
                    EntityTag = new Microsoft.Net.Http.Headers.EntityTagHeaderValue("\"" + new FileInfo(filePath).LastWriteTimeUtc.Ticks.ToString("x") + "\""),
                    LastModified = new FileInfo(filePath).LastWriteTimeUtc,
                    FileDownloadName = Path.GetFileName(filePath)
                };
            }
            else
            {
                return new FileStreamResult(fileStream, contentType);
            }
        }

        private string GetContentType(string path)
        {
            var types = GetMimeTypes();
            var ext = Path.GetExtension(path).ToLowerInvariant();
            return types[ext];
        }

        private Dictionary<string, string> GetMimeTypes()
        {
            return new Dictionary<string, string>
            {
                {".mp3", "audio/mpeg"},
                {".wav", "audio/wav"},
                {".mid", "audio/midi"},
                {".midi", "audio/midi"},
                // Add more if needed
            };
        }


        //[HttpGet("{userId}/{fileName}")]
        //public async Task<IActionResult> GetTrack(string userId, string trackId)
        //{
        //    var userDirectoryPath = Path.Combine(_storagePath, userId);
        //    var filePath = Path.Combine(userDirectoryPath, trackId);

        //    if (!System.IO.File.Exists(filePath))
        //    {
        //        return NotFound();
        //    }

        //    var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
        //    var contentType = GetContentType(filePath);
        //    var fileLength = fileStream.Length;
        //    var range = Request.Headers["Range"].ToString();

        //    if (!string.IsNullOrEmpty(range))
        //    {
        //        var rangeStart = long.Parse(range.Replace("bytes=", "").Split('-')[0]);
        //        var rangeEnd = rangeStart + _bufferSize;

        //        if (rangeEnd > fileLength)
        //        {
        //            rangeEnd = fileLength;
        //        }

        //        var lengthToRead = rangeEnd - rangeStart;
        //        var buffer = new byte[lengthToRead];
        //        fileStream.Seek(rangeStart, SeekOrigin.Begin);
        //        await fileStream.ReadAsync(buffer, 0, (int)lengthToRead);

        //        Response.StatusCode = 206;
        //        Response.Headers.Add("Content-Range", $"bytes {rangeStart}-{rangeEnd}/{fileLength}");

        //        return File(buffer, contentType);
        //    }
        //    else
        //    {
        //        return File(fileStream, contentType);
        //    }
        //}

    }
}