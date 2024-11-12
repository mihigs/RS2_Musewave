using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IUserRepository : IRepository<User>
    {
        Task<User> GetAdminUser();
        Task<int> GetUserCount(bool withArtists = true, int? month = null, int? year = null);
        Task<User> GetUserByName(string name);
        Task<User> GetUserById(string id);
    }
}
