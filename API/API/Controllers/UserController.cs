using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using Services.Responses;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly IUsersService _usersService;
        private readonly ILogger<UserController> _logger;
        private readonly ILanguageService _languageService;

        public UserController(UserManager<User> userManager, IUsersService usersService, ILogger<UserController> logger, ILanguageService languageService)
        {
            _userManager = userManager;
            _usersService = usersService;
            _logger = logger;
            _languageService = languageService;
        }

        [AllowAnonymous]
        [HttpPost("Login")]
        public async Task<IActionResult> Login(UserLogin model)
        {
            if (model.Email.IsNullOrEmpty() || model.Password.IsNullOrEmpty())
            {
                return BadRequest();
            }
            try
            {
                UserLoginResponse response = await _usersService.Login(model);
                if (response.Token != null)
                {
                    var user = await _userManager.FindByEmailAsync(model.Email);
                    var language = await _languageService.GetLanguageById(user.LanguageId);
                    var roles = await _userManager.GetRolesAsync(user);
                    if (roles.Contains("Admin"))
                    {
                        return Ok(new { response.Token, Role = "Admin", LanguageCode = language.Code });
                    }
                    else
                    {
                        return Ok(new { response.Token, Role = "User", LanguageCode = language.Code });
                    }
                }
                else if (response.Error == LoginError.UserDoesNotExist)
                {
                    return NotFound();
                }
                else if (response.Error == LoginError.InvalidLoginCredentials)
                {
                    return Unauthorized();
                }
                return BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error logging in user");
                return BadRequest();
            }
        }

        [AllowAnonymous]
        [HttpPost("NewUser")]
        public async Task<IActionResult> AddUser(UserLogin model)
        {
            var token = await _usersService.AddUser(model);
            if (token != null)
            {
                return Ok(new { token });
            }
            return BadRequest();
        }

        [HttpGet("GetUserDetails")]
        public async Task<ApiResponse> GetUserDetails()
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
                apiResponse.Data = await _usersService.GetUserDetails(userId);
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

        [HttpGet("GetHomepageDetails")]
        public async Task<ApiResponse> GetHomepageDetails()
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
                apiResponse.Data = await _usersService.GetHomepageDetails(userId);
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

        [HttpGet("GetAllLanguages")]
        public async Task<ApiResponse> GetAllLanguages()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _languageService.GetAllLanguages();
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

        [HttpPost("UpdatePreferedLanguage")]
        public async Task<ApiResponse> UpdatePreferedLanguage(int languageId)
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
                await _usersService.UpdatePreferedLanguage(userId, languageId);
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

        [HttpGet("GetAllUsers")]
        public async Task<ApiResponse> GetAllUsers()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = _userManager.Users;
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
