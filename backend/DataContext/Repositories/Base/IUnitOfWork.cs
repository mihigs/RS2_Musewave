using Models.Entities;

namespace DataContext.Repositories
{
    public interface IUnitOfWork : IDisposable
    {
        Task<int> SaveChangesAsync();
        User GetCurrentUser();
        void SetCurrentUser(User user);
        string GetCurrentUserId();
    }
}
