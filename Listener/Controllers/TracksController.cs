﻿using Listener.Models.DTOs;
using Listener.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Text;

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
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                await _trackService.StoreTrack(model);
                apiResponse.Data = "Track started upload";
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Accepted(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }
        [HttpGet("Stream/{trackId}")]
        public async Task<IActionResult> Stream(string trackId, string token)
        {
            var artistId = "";
            try
            {
                // Verify the token and authorize the user...
                var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("your-secret-key-needs-to-be-at-least-128-bits"));
                var tokenHandler = new JwtSecurityTokenHandler();
                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = secretKey,
                    ValidateIssuer = false,
                    ValidateAudience = false
                };

                SecurityToken validatedToken;
                try
                {
                    tokenHandler.ValidateToken(token, validationParameters, out validatedToken);

                    // Get the artistId from the token...
                    var jwtToken = (JwtSecurityToken)validatedToken;
                    artistId = jwtToken.Claims.First(x => x.Type == "artistId").Value;
                }
                catch
                {
                    throw new SecurityTokenValidationException("Invalid token");
                }

                // If the token is valid, stream the audio file...
                // First get the buffer size from the request headers...
                var range = Request.Headers["Range"].ToString();

                var (stream, contentType, rangeStart, rangeEnd, totalLength, filePath) = await _trackService.HandleTrackStreamRequest(trackId, artistId, range);

                if (!string.IsNullOrEmpty(range))
                {
                    Response.StatusCode = (int)HttpStatusCode.PartialContent;
                    Response.Headers.Append("Content-Range", $"bytes {rangeStart}-{rangeEnd}/{totalLength}");
                }
                else
                {
                    Response.StatusCode = (int)HttpStatusCode.OK;
                }

                Response.Headers.Append("Accept-Ranges", "bytes");
                Response.Headers.Append("Content-Length", (totalLength).ToString());
                Response.Headers.Append("ETag", $"\"{CalculateETag(filePath)}\"");
                Response.Headers.Append("Content-Type", contentType);

                return new FileStreamResult(stream, contentType);

                //var (stream, contentType, rangeStart, rangeEnd, totalLength) = await _trackService.HandleTrackStreamRequest(trackId, artistId);

                //return new FileStreamResult(stream, contentType);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                throw;
            }
        }

        private string CalculateETag(string filePath)
        {
            var fileInfo = new FileInfo(filePath);
            var lastModifiedTime = fileInfo.LastWriteTimeUtc.Ticks;
            var eTag = Convert.ToBase64String(BitConverter.GetBytes(lastModifiedTime));
            return eTag;
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
