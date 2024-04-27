using Models.Entities;

namespace DataContext.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly MusewaveDbContext _context;
        private User _currentUser;
        public UnitOfWork(MusewaveDbContext context)
        {
            _context = context;
        }
        public void Dispose()
        {
            _context.Dispose();
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public User GetCurrentUser()
        {
            return _currentUser;
        }

        public void SetCurrentUser(User user)
        {
            _currentUser = user;
        }
        public string GetCurrentUserId()
        {
            return _currentUser.Id;
        }
    }
}
