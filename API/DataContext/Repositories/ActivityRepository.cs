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

        public async Task<int> GetDailyLoginCount()
        {
            var today = DateTime.UtcNow.Date;
            return await _dbContext.Set<Activity>().CountAsync(x => x.CreatedAt.Date == today && x.ActivityType == ActivityType.UserLogin);
        }
        public async Task<int> GetJamendoAPIRequestCountPerMonth()
        {
            var today = DateTime.UtcNow.Date;
            return await _dbContext.Set<Activity>()
                .CountAsync(x => x.CreatedAt.Date == today && CheckIfActivityIsJamendoAPIRequest(x.ActivityType));
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
