using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace API.Controllers
{
    [ApiController]
    //[Authorize(Roles = Role.ADMIN)]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;
        public AdminController(IAdminService adminService)
        {
            _adminService = adminService;
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

    }
}
