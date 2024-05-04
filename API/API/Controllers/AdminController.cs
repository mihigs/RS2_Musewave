using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace API.Controllers
{
    [ApiController]
    [Authorize(Roles = Role.ADMIN)]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;
        private readonly IGenreSimilarityTrackerService _genreSimilarityTrackerService;
        public AdminController(IAdminService adminService, IGenreSimilarityTrackerService genreSimilarityTrackerService)
        {
            _adminService = adminService;
            _genreSimilarityTrackerService = genreSimilarityTrackerService;
        }

        [HttpGet]
        [Route("GetDashboardDetails")]
        public async Task<ApiResponse> GetDashboardDetails()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _adminService.GetDashboardDetails();
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

        [HttpGet]
        [Route("GetSimilarityMatrix")]
        public async Task<ApiResponse> GetSimilarityMatrix()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _genreSimilarityTrackerService.GetSimilarityMatrixDtoAsync();
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

        [HttpGet]
        [Route("UpdateSimilarityMatrix")]
        public async Task<ApiResponse> UpdateSimilarityMatrix()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _genreSimilarityTrackerService.CalculateAndStoreGenreSimilarities();
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
