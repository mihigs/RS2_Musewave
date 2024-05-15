using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IUserRepository : IRepository<User>
    {
        Task<User> GetAdminUser();
        Task<int> GetUserCount();
        Task<User> GetUserByName(string name);
        Task<User> GetUserById(string id);
    }
}
