using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class LoginActivityRepository : Repository<LoginActivity>, ILoginActivityRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public LoginActivityRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task AddLoginActivity(string userId, bool isSuccessful)
        {
            var loginActivity = new LoginActivity
            {
                UserId = userId,
                IsSuccessful = isSuccessful,
            };

            await _dbContext.Set<LoginActivity>().AddAsync(loginActivity);

            await _dbContext.SaveChangesAsync();
        }

        public async Task<int> GetDailyLoginCount()
        {
            var today = DateTime.UtcNow.Date;
            return await _dbContext.Set<LoginActivity>().CountAsync(x => x.CreatedAt.Date == today);
        }
    }
}
