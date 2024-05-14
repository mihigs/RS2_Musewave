
using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Models.Constants;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using Services.Responses;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Services.Implementations
{
    public class UsersService : IUsersService
    {
        private readonly UserManager<User> _userManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<UsersService> _logger;
        private readonly IPlaylistRepository _playlistRepository;
        private readonly IJamendoService _jamendoService;
        private readonly ILoginActivityRepository _loginActivityRepository;

        public UsersService(
            UserManager<User> userManager,
            IConfiguration configuration,
            ILogger<UsersService> logger,
            IPlaylistRepository playlistRepository,
            IJamendoService jamendoService,
            ILoginActivityRepository loginActivityRepository
            )
        {
            _userManager = userManager;
            _configuration = configuration;
            _logger = logger;
            _playlistRepository = playlistRepository;
            _jamendoService = jamendoService;
            _loginActivityRepository = loginActivityRepository;
        }

        public List<User> GetAllUsers()
        {
            try
            {
                return _userManager.Users.ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting all users: {ex.Message}");
                throw;
            }
        }

        public async Task<UserLoginResponse> Login(UserLogin model)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(model.Email);
                if (user is null)
                {
                    return new UserLoginResponse { Error = LoginError.UserDoesNotExist };
                }

                // Get user roles
                var userRoles = await _userManager.GetRolesAsync(user);

                var result = await _userManager.CheckPasswordAsync(user, model.Password);
                if (result)
                {
                    // Log successful login
                    await _loginActivityRepository.AddLoginActivity(userId: user.Id, isSuccessful: true);
                    // Return generated token
                    return new UserLoginResponse { Token = GenerateJwtToken(user, userRoles.ToList()) };
                }
                else
                {
                    // Log unsuccessful login
                    await _loginActivityRepository.AddLoginActivity(userId: user.Id, isSuccessful: false);
                    return new UserLoginResponse { Error = LoginError.InvalidLoginCredentials };
                }
            }
            catch (Exception ex)
            {
                //Log error
                throw new Exception("Error logging in user", ex);
            }

        }

        public async Task<string> AddUser(UserLogin model)
        {
            try
            {
                var user = new User
                {
                    UserName = model.Email,
                    Email = model.Email
                };

                var result = await _userManager.CreateAsync(user, model.Password); // Create user with password
                var userRoles = await _userManager.AddToRoleAsync(user, Role.USER); // Assign user role
                if (result.Succeeded)
                {
                    var token = GenerateJwtToken(user, [Role.USER]); // Generate JWT token
                    return token;
                }
                else if (result.Errors.Any())
                {
                    throw new Exception(string.Join(", ", result.Errors.Select(e => e.Description)));
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding user");
                return null;
            }
        }

        public async Task<User> GetUserDetails(string userId)
        {
            try
            {
                User result = await _userManager.FindByIdAsync(userId);
                if (result is null)
                {
                    throw new Exception("User not found");
                }
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting user details: {ex.Message}");
                throw new Exception("Error getting user details", ex);
            }
        }

        private string GenerateJwtToken(User user, List<string> userRoles)
        {
            try
            {
                var claims = GetClaims(user, userRoles);
                var signingCredentials = GetSigningCredentials();
                var expires = GetExpirationTime();

                var token = new JwtSecurityToken(
                    issuer: _configuration["Jwt:Issuer"],
                    audience: _configuration["Jwt:Issuer"],
                    claims: claims,
                    expires: expires,
                    signingCredentials: signingCredentials
                );

                return new JwtSecurityTokenHandler().WriteToken(token);
            }
            catch (Exception ex)
            {
                // Log error
                throw new Exception("Error generating JWT token", ex);
            }
        }

        private IEnumerable<Claim> GetClaims(User user, List<string> userRoles)
        {
            var roleClaims = userRoles.Select(role => new Claim(ClaimTypes.Role, role));
            var allClaims = new List<Claim>
            {
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.NameIdentifier, user.Id),
            };
            allClaims.AddRange(roleClaims);
            return allClaims;
        }

        private SigningCredentials GetSigningCredentials()
        {
            var key = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]));
            return new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        }

        private DateTime GetExpirationTime()
        {
            return DateTime.Now.AddSeconds(Convert.ToDouble(_configuration["Jwt:AccessExpirationSeconds"]));
        }

        public async Task<HomepageDetailsDto> GetHomepageDetails(string userId)
        {
            try
            {
                // Get user details
                var user = await _userManager.FindByIdAsync(userId);
                if (user is null)
                {
                    throw new Exception("User not found");
                }

                // Get ExploreWeeklyPlaylistId
                var exploreWeeklyPlaylistId = await _playlistRepository.GetExploreWeeklyPlaylistId(userId);

                // Get PopularJamendoTracks
                var popularJamendoTracks = await _jamendoService.GetPopularJamendoTracks();

                return new HomepageDetailsDto
                {
                    ExploreWeeklyPlaylistId = exploreWeeklyPlaylistId,
                    PopularJamendoTracks = popularJamendoTracks.ToList(),
                };
            }
            catch (Exception ex)
            {
                // Log error
                throw new Exception("Error getting homepage details", ex);
            }
        }
    }
}
