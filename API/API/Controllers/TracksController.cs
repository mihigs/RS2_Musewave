using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Implementations;
using Services.Interfaces;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TracksController : ControllerBase
    {
        private readonly ITracksService _tracksService;
        private readonly IListenerService _listenerService;
        private readonly IJamendoService _jamendoService;

        public TracksController(ITracksService tracksService, IListenerService listenerService, IJamendoService jamendoService)
        {
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
            _listenerService = listenerService ?? throw new ArgumentNullException(nameof(listenerService));
            _jamendoService = jamendoService;
        }

        [HttpGet("GetTracks")]
        public async Task<IActionResult> GetTracks([FromQuery] TrackQuery query)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var results = await _tracksService.GetTracksAsync(query);

                if (results == null || !results.Any())
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("No tracks found");
                    return Ok(apiResponse);
                }

                apiResponse.Data = results;
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


        [HttpGet("GetTrackDetails")]
        public async Task<IActionResult> GetTrackDetails(int trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                Track trackResult = null;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim != null)
                {
                    string userId = userIdClaim.Value;
                    trackResult = await _tracksService.GetTrackByIdAsync(trackId, userId);
                }
                if (trackResult is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Track not found");
                    return NotFound(apiResponse);
                }

                apiResponse.Data = trackResult;
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

        [HttpGet("GetJamendoTracks")]
        public async Task<ApiResponse> GetJamendoTracks([FromQuery] JamendoTrackQuery query)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // Get the userId from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                var userId = userIdClaim.Value;
                var results = await _jamendoService.GetJamendoTracksAsync(query, userId);

                if (results == null || !results.Any())
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("No tracks found");
                    return apiResponse;
                }

                apiResponse.Data = results;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return apiResponse;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpGet("GetJamendoTrackDetails")]
        public async Task<IActionResult> GetJamendoTrackDetails(int jamendoId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                var trackResult = await _jamendoService.GetTrackById(jamendoId, userId);
                if (trackResult is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Jamendo track not found");
                    return NotFound(apiResponse);
                }

                apiResponse.Data = trackResult;
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

        [HttpGet("GetMyTracks")]
        public async Task<IActionResult> GetMyTracks()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.GetTracksByUserId(userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return Ok(apiResponse);
        }

        [HttpGet("GetMyLikedTracks")]
        public async Task<ApiResponse> GetMyLikedTracks()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
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

        [HttpPost("UploadTrack")]
        public async Task<IActionResult> UploadTrack(TrackUploadDetailsDto model)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // Check if file is not empty
                if (model.mediaFile is null || model.mediaFile.Length == 0)
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
                apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
                return CreatedAtAction(nameof(UploadTrack), apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpPost("GetNextTrack")]
        public async Task<IActionResult> GetNextTrack([FromBody] GetNextTrackRequestDto getNextTrackDto)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // gets the user id from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                // gets the next track based on the streaming context type
                var nextTrack = await _tracksService.GetNextTrackAsync(getNextTrackDto, userId);
                if (nextTrack is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Track not found");
                    return NotFound(apiResponse);
                }
                apiResponse.Data = nextTrack;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                return StatusCode((int)apiResponse.StatusCode, apiResponse);
            }
        }

        [HttpPost("ToggleLikeTrack")]
        public async Task<IActionResult> ToggleLikeTrack(int trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.ToggleLikeTrack(trackId, userId);
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

        [HttpGet("GetTrackComments")]
        public async Task<IActionResult> GetTrackComments(int trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var comments = await _tracksService.GetTrackComments(trackId);
                if (comments is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Comments not found");
                    return NotFound(apiResponse);
                }
                apiResponse.Data = comments;
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

        [HttpPost("AddTrackComment")]
        public async Task<IActionResult> AddTrackComment(CommentDto commentDto)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                var userId = userIdClaim.Value;
                var newComment = await _tracksService.AddCommentToTrack(commentDto.TrackId, commentDto.Comment, userId);
                if (newComment is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("Comment not added");
                    return BadRequest(apiResponse);
                }
                apiResponse.Data = newComment;
                apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
                return CreatedAtAction(nameof(AddTrackComment), apiResponse);
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
