using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Models.DTOs;
using DataContext.Repositories;
using System.Security.Claims;
using Services.Interfaces;
using Services.Implementations;
using System.Linq;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TracksController : ControllerBase
    {
        private readonly ITracksService _tracksService;
        private readonly IListenerService _listenerService;
        public TracksController(ITracksService tracksService, IListenerService listenerService)
        {
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
            _listenerService = listenerService ?? throw new ArgumentNullException(nameof(listenerService));
        }

        [HttpGet("GetLikedTracks")]
        public async Task<ApiResponse> GetLikedTracks()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.GetLikedTracksAsync(userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpGet("GetTracksByName")]
        public async Task<ApiResponse> GetTracksByName(string name)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _tracksService.GetTracksByNameAsync(name);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpPost("UploadTrack")]
        public async Task<IActionResult> UploadTrack(TrackUploadDetailsDto model)
        {
            // Check if file is not empty
            if (model.mediaFile == null || model.mediaFile.Length == 0)
            {
                return BadRequest("File cannot be empty");
            }
            // Check if trackName is not empty
            if (string.IsNullOrWhiteSpace(model.trackName))
            {
                return BadRequest("Track name cannot be empty");
            }
            // Check if userId is not empty
            if (string.IsNullOrWhiteSpace(model.userId))
            {
                return BadRequest("User ID cannot be empty");
            }
            // Check if file size is less than 10MB
            if (model.mediaFile.Length > 10 * 1024 * 1024) // 10MB in bytes
            {
                return BadRequest("File size cannot exceed 10MB");
            }

            // Check if file type is .mp3, .midi, .mid or .wav
            var allowedExtensions = new[] { ".mp3", ".midi", ".mid", ".wav" };
            var fileExtension = Path.GetExtension(model.mediaFile.FileName).ToLower();

            if (!allowedExtensions.Contains(fileExtension))
            {
                return BadRequest("Invalid file type. Only .mp3, .midi, .mid and .wav files are allowed");
            }

            // If file is valid, send it to the Listener to be processed
            await _listenerService.TrackUploadRequest(model);

            // Return a 201 Created response
            return CreatedAtAction(nameof(UploadTrack), new { fileName = model.mediaFile.FileName });
        }

        [HttpGet("getTrack/{trackId}")]
        public async Task<IActionResult> GetTrack(string trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _tracksService.GetTrackByIdAsync(int.Parse(trackId));
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }


    }
}
