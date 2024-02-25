
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Models.Entities;
using Models.DTOs;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Services.Responses;

namespace Services.Implementations
{
    public class UsersService
    {
        private readonly UserManager<User> _userManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<UsersService> _logger;

        public UsersService(
            UserManager<User> userManager,
            IConfiguration configuration,
            ILogger<UsersService> logger
            )
        {
            _userManager = userManager;
            _configuration = configuration;
            _logger = logger;
        }

        public List<User> GetAllUsers()
        {
            try
            {
                return _userManager.Users.ToList();
            }
            catch (Exception ex)
            {
                //Log error
                throw;
            }
        }

        public async Task<UserLoginResponse> Login(UserLogin model)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(model.Email);
                if (user == null)
                {
                    return new UserLoginResponse { Error = LoginError.UserDoesNotExist };
                }

                var result = await _userManager.CheckPasswordAsync(user, model.Password);
                if (result)
                {
                    // Return generated token
                    return new UserLoginResponse { Token = GenerateJwtToken(user) };
                }
                else
                {
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
                if (result.Succeeded)
                {
                    var token = GenerateJwtToken(user); // Generate JWT token
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
                //Log error
                _logger.LogError(ex, "Error adding user");
                return null;
            }
        }

        private string GenerateJwtToken(User user)
        {
            try
            {
                var claims = GetClaims(user);
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

        private IEnumerable<Claim> GetClaims(User user)
        {
            return new List<Claim>
            {
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            };
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


        //public async Task<PaginationResponseDto> FilterUsers(FilterUsersDto model)
        //{
        //    try
        //    {
        //        var users = _userManager.Users.ToList();
        //        var results = new PaginationResponseDto();
        //        var totalCount = users.Count();
        //        if (!string.IsNullOrEmpty(model.Email))
        //        {
        //            users = users.Where(u => u.Email.Contains(model.Email)).ToList();
        //        }
        //        if (!string.IsNullOrEmpty(model.SortBy))
        //        {
        //            if (model.SortDescending == true)
        //            {
        //                users = users.OrderByDescending(u => u.Email).ToList();
        //            }
        //            else
        //            {
        //                users = users.OrderBy(u => u.Email).ToList();
        //            }
        //        }
        //        if (model.PageNumber != null && model.PageSize != null)
        //        {
        //            users = users.Skip((model.PageNumber.Value) * model.PageSize.Value).Take(model.PageSize.Value).ToList();
        //        }

        //        results.Rows.AddRange(users);
        //        results.TotalCount = totalCount;

        //        return results;
        //    }
        //    catch (Exception)
        //    {
        //        //Log error
        //        throw;
        //    }
        //}
    }
}
