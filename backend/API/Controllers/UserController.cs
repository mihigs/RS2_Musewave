
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Models.Entities;
using Models.DTOs;
using Services.Implementations;
using Services.Responses;
using Microsoft.IdentityModel.Tokens;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly UsersService _usersService;

        public UserController(UserManager<User> userManager, UsersService usersService)
        {
            _userManager = userManager;
            _usersService = usersService;
        }

        [HttpGet("allUsers")]
        public async Task<ActionResult> GetAllUsers()
        {
            try
            {
                var users = _userManager.Users.ToList();

                return Ok(users);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
                throw;
            }
        }

        [AllowAnonymous]
        [HttpPost("login")]
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
                    return Ok(new { response.Token });
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
                // Log error
                return BadRequest();
            }
        }

        [HttpPost("newUser")]
        public async Task<IActionResult> AddUser(UserLogin model)
        {
            var token = await _usersService.AddUser(model);
            if (token != null)
            {
                return Ok(new { token });
            }
            return BadRequest();
        }
    }
}
