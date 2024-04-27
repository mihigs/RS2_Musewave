using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IUserRepository : IRepository<User>
    {
        Task<User> GetAdminUser();
    }
}
