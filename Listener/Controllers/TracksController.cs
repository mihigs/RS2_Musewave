using Listener.Models.DTOs;
using Listener.Services;
using Microsoft.AspNetCore.Mvc;

namespace Listener
{
    [Route("api/[controller]")]
    [ApiController]
    public class TracksController : ControllerBase
    {
        private readonly ITrackService _trackService;

        public TracksController(ITrackService trackService)
        {
            _trackService = trackService;
        }

        [HttpPost("UploadTrack")]
        public async Task<IActionResult> UploadTrack(TrackUploadDto model)
        {
            _trackService.ProcessTrack(model);

            return Accepted();
        }

        //[HttpGet("{userId}/{fileName}")]
        //public async Task<IActionResult> GetTrack(string userId, string fileName)
        //{
        //    var userDirectoryPath = Path.Combine(_storagePath, userId);
        //    var filePath = Path.Combine(userDirectoryPath, fileName);

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
