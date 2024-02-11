
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.DTOs;
using Services.Implementations;

namespace API.Controllers
{
    //[Authorize]
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
            var token = await _usersService.Login(model);
            if (token != null)
            {
                return Ok(new{ token });
            }
            return Unauthorized(); // Invalid login credentials or the user does not exist
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
