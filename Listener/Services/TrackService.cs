using Listener.Models.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Listener.Services
{
    public class TrackService : ITrackService
    {
        private readonly string _storagePath;
        private readonly IRabbitMqService _rabbitMqService;
        private const int _bufferSize = 1 * 1024 * 1024; // 1MB
        private long _fileStreamPosition = 0;

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

        public async Task<(Stream, string, long, long, long, string)> HandleTrackStreamRequest(string trackId, string artistId, string range = null)
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

            // If range is specified, adjust the file stream position accordingly
            if (range != null && range.StartsWith("bytes="))
            {
                var rangeStart = long.Parse(range.Substring(6).Split('-')[0]);
                var rangeEnd = Math.Min(rangeStart + _bufferSize, fileLength - 1);

                _fileStreamPosition = rangeStart;
                fileStream.Position = _fileStreamPosition;

                var lengthToRead = rangeEnd - rangeStart + 1;
                return (fileStream, contentType, rangeStart, rangeEnd, fileLength, filePath);
            }
            else
            {
                // If no range is specified, return the entire file
                return (fileStream, contentType, 0, fileLength - 1, fileLength, filePath);
            }

            //if (range != null || !string.IsNullOrEmpty(range))
            //{
            //    var rangeStart = long.Parse(range.Replace("bytes=", "").Split('-')[0]);
            //    var rangeEnd = rangeStart + _bufferSize;

            //    if (rangeEnd > fileLength)
            //    {
            //        rangeEnd = fileLength;
            //    }

            //    var lengthToRead = rangeEnd - rangeStart;
            //    var buffer = new byte[lengthToRead];
            //    fileStream.Seek(rangeStart, SeekOrigin.Begin);
            //    await fileStream.ReadAsync(buffer, 0, (int)lengthToRead);

            //    return (new MemoryStream(buffer), contentType, rangeStart, rangeEnd, fileLength, filePath);
            //}
            //else
            //{
            //    return (fileStream, contentType, 0, fileLength, fileLength, filePath);
            //}
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

    }
}
