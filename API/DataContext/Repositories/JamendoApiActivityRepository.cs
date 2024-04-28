using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;
using Models.Enums;

namespace DataContext.Repositories
{
    public class JamendoApiActivityRepository : Repository<JamendoAPIActivity>, IJamendoApiActivityRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public JamendoApiActivityRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task AddJamendoApiActivity(JamendoAPIActivityType activityType, string userId = null)
        {
            var loginActivity = new JamendoAPIActivity
            {
                UserId = userId,
                ActivityType = activityType,
            };

            await _dbContext.Set<JamendoAPIActivity>().AddAsync(loginActivity);

            await _dbContext.SaveChangesAsync();
        }

        public async Task<int> GetJamendoAPIRequestCountPerMonth()
        {
            var today = DateTime.UtcNow.Date;
            return await _dbContext.Set<JamendoAPIActivity>().CountAsync(x => x.CreatedAt.Date == today);
        }
    }
}
