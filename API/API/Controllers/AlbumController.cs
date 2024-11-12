using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.DTOs.Queries;
using Services.Interfaces;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AlbumController : ControllerBase
    {
        private readonly IAlbumService _albumService;

        public AlbumController(IAlbumService albumService)
        {
            _albumService = albumService ?? throw new ArgumentNullException(nameof(albumService));
        }

        [HttpGet("GetAlbums")]
        public async Task<IActionResult> GetAlbums([FromQuery] AlbumQuery query)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    return BadRequest("User not found");
                }
                query.UserId = userIdClaim.Value;

                var results = await _albumService.GetAlbumsAsync(query);

                if (results == null || !results.Any())
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("No albums found");
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

        [HttpGet("GetAlbumDetails")]
        public async Task<ApiResponse> GetAlbumDetails(int albumId)
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
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _albumService.GetAlbumDetails(albumId, userId);
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
