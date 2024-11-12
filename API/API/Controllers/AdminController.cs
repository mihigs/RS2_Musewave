using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTOs;
using Models.DTOs.Queries;
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
        private readonly IReportingService _reportingService;
        public AdminController(IAdminService adminService, IGenreSimilarityTrackerService genreSimilarityTrackerService, IReportingService reportingService)
        {
            _adminService = adminService;
            _genreSimilarityTrackerService = genreSimilarityTrackerService;
            _reportingService = reportingService;
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
        [Route("RefreshSimilarityMatrix")]
        public async Task<ApiResponse> RefreshSimilarityMatrix()
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

        [HttpGet("GetReports")]
        public async Task<ApiResponse> GetReports([FromQuery] ReportsQuery query)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _reportingService.GetReportsAsync(query);
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

        [HttpGet("GenerateReport")]
        public async Task<ApiResponse> GenerateReport(int? month = null, int? year = null)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _reportingService.GenerateMonthlyReportAsync(month, year);
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

        [HttpGet("ExportReportAsPDF")]
        public async Task<IActionResult> ExportReportAsPDF(int reportId)
        {
            try
            {
                var report = await _reportingService.ExportReportAsPDF(reportId);
                return File(report, "application/pdf");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
