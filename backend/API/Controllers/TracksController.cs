using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Models.DTOs;
using DataContext.Repositories;
using System.Security.Claims;
using Services.Interfaces;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TracksController : ControllerBase
    {
        private readonly ITracksService _tracksService;
        public TracksController(ITracksService tracksService)
        {
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
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
    }
}
