using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;
using Models.Enums;

namespace DataContext.Repositories
{
    public class ActivityRepository : Repository<Activity>, IActivityRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public ActivityRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task AddActivity(string? userId, ActivityType activityType, bool? isSuccessful)
        {
            var loginActivity = new Activity
            {
                UserId = userId,
                IsSuccessful = isSuccessful,
                ActivityType = activityType,
                IsJamendoApiRequest = CheckIfActivityIsJamendoAPIRequest(activityType)
            };

            await _dbContext.Set<Activity>().AddAsync(loginActivity);

            await _dbContext.SaveChangesAsync();
        }

        public async Task<int> GetDailyLoginCount(int? month = null, int? year = null)
        {
            var query = _dbContext.Set<Activity>()
                .Where(x => x.ActivityType == ActivityType.UserLogin);

            if (month.HasValue && year.HasValue)
            {
                query = query.Where(x => x.CreatedAt.Month == month.Value && x.CreatedAt.Year == year.Value);
            }
            else if (month.HasValue)
            {
                query = query.Where(x => x.CreatedAt.Month == month.Value);
            }
            else if (year.HasValue)
            {
                query = query.Where(x => x.CreatedAt.Year == year.Value);
            }
            else
            {
                var today = DateTime.UtcNow.Date;
                query = query.Where(x => x.CreatedAt.Date == today);
            }

            return await query.CountAsync();
        }

        public async Task<int> GetJamendoAPIRequestCountPerMonth(int? month = null, int? year = null)
        {
            var today = DateTime.UtcNow;
            int targetYear = year ?? today.Year;
            int targetMonth = month ?? today.Month;

            var startOfMonth = new DateTime(targetYear, targetMonth, 1);
            var endOfMonth = startOfMonth.AddMonths(1);

            return await _dbContext.Set<Activity>()
                .CountAsync(x => x.CreatedAt >= startOfMonth && x.CreatedAt < endOfMonth && x.IsJamendoApiRequest);
        }


        private bool CheckIfActivityIsJamendoAPIRequest(ActivityType activityType)
        {
            return activityType == ActivityType.SearchJamendoByTrackName ||
                activityType == ActivityType.GetJamendoTrackById ||
                activityType == ActivityType.GetJamendoTracksPerGenres ||
                activityType == ActivityType.GetPopularJamendoTracks ||
                activityType == ActivityType.GetJamendoArtistDetails;
        }
    }
}
