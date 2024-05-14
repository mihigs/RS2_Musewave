using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ILoginActivityRepository : IRepository<LoginActivity>
    {
        Task AddLoginActivity(string userId, bool isSuccessful);
        Task<int> GetDailyLoginCount();
    }
}
