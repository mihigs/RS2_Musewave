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
    public class MoodTrackerController : ControllerBase
    {
        private readonly IMoodTrackerService _moodTrackerService;

        public MoodTrackerController(IMoodTrackerService moodTrackerService)
        {
            _moodTrackerService = moodTrackerService ?? throw new ArgumentNullException(nameof(moodTrackerService));
        }

        [HttpGet("GetMoodTrackers")]
        public async Task<ApiResponse> GetMoodTrackers([FromQuery] MoodTrackersQuery query)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var results = await _moodTrackerService.GetMoodTrackers(query);

                if (results == null || !results.Any())
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("No mood trackers found");
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
                return apiResponse;
                throw;
            }
        }

        [HttpPost("RecordMood")]
        public async Task<ApiResponse> RecordMood(MoodTrackerDto moodTrackerDto)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                MoodTracker moodTrackerEntry = new MoodTracker
                {
                    UserId = moodTrackerDto.UserId,
                    Description = moodTrackerDto.Description,
                    MoodType = moodTrackerDto.MoodType,
                    RecordDate = moodTrackerDto.RecordDate
                };
                await _moodTrackerService.RecordMoodAsync(moodTrackerEntry);
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

        //[HttpGet("GetArtists")]
        //public async Task<IActionResult> GetArtists([FromQuery] ArtistQuery query)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        //        if (userIdClaim == null)
        //        {
        //            return BadRequest("User not found");
        //        }
        //        query.UserId = userIdClaim.Value;

        //        var results = await _moodTrackerService.GetArtistsAsync(query);

        //        if (results == null || !results.Any())
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            apiResponse.Errors.Add("No artists found");
        //            return Ok(apiResponse);
        //        }

        //        apiResponse.Data = results;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //        return Ok(apiResponse);
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //}

        //[HttpGet("GetArtistDetails")]
        //public async Task<ApiResponse> GetArtistDetails(int artistId, bool isJamendoArtist = false)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        apiResponse.Data = await _moodTrackerService.GetArtistDetailsAsync(artistId, isJamendoArtist);
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}
    }
}
