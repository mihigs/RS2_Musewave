using Models.DTOs;
using Models.Entities;
using Services.Responses;

namespace Services.Interfaces
{
    public interface IUsersService
    {
        List<User> GetAllUsers();
        Task<UserLoginResponse> Login(UserLogin model);
        Task<string> AddUser(UserLogin model);
    }
}
