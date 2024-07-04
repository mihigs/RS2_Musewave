using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Implementations;
using Services.Interfaces;
using System.Security.Claims;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService _searchService;
        private readonly ITracksService _tracksService;

        public SearchController(ISearchService searchHistoryService, ITracksService tracksService)
        {
            _searchService = searchHistoryService ?? throw new ArgumentNullException(nameof(searchHistoryService));
            _tracksService = tracksService;
        }

        [HttpGet("GetSearchHistory")]
        public async Task<IActionResult> GetSearchHistory()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim != null)
                {
                    string userId = userIdClaim.Value;
                    var results = await _searchService.GetSearchHistorysAsync(userId);
                    apiResponse.Data = results;
                    apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                    return Ok(apiResponse);
                }

                apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                return BadRequest(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpPost("RemoveSearchHistory")]
        public async Task<IActionResult> RemoveSearchHistory(int searchHistoryId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim != null)
                {
                    string userId = userIdClaim.Value;
                    await _searchService.RemoveSearchHistoryAsync(searchHistoryId);
                    apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                    return Ok(apiResponse);
                }

                apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                return BadRequest(apiResponse);
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
