using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.DTOs.Queries;
using Services.Implementations;
using Services.Interfaces;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ArtistController : ControllerBase
    {
        private readonly IArtistService _artistService;

        public ArtistController(IArtistService artistService)
        {
            _artistService = artistService ?? throw new ArgumentNullException(nameof(artistService));
        }

        [HttpGet("GetArtists")]
        public async Task<IActionResult> GetArtists([FromQuery] ArtistQuery query)
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

                var results = await _artistService.GetArtistsAsync(query);

                if (results == null || !results.Any())
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("No artists found");
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

        [HttpGet("GetArtistDetails")]
        public async Task<ApiResponse> GetArtistDetails(int artistId, bool isJamendoArtist = false)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _artistService.GetArtistDetailsAsync(artistId, isJamendoArtist);
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
