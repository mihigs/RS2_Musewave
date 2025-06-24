using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.DTOs.Queries;
using Models.Entities;

namespace DataContext.Repositories
{
    public class MoodTrackerRepository : Repository<MoodTracker>, IMoodTrackerRepository
    {
        private readonly MusewaveDbContext _dbContext;
        public MoodTrackerRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<MoodTracker?> GetDuplicateRecord(string userId, DateTime recordDate)
        {
            return await _dbContext.Set<MoodTracker>()
                .Include(x => x.User)
                .Where(a => a.UserId == userId && a.RecordDate.Date == recordDate.Date)
                .FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<MoodTracker>> GetMoodTrackers(MoodTrackersQuery moodTrackersQuery)
        {
            var query = _dbContext.Set<MoodTracker>().Include(m => m.User);

            if (moodTrackersQuery.UserId != null)
            {
                query.Where(m => m.UserId == moodTrackersQuery.UserId);
            }

            if (moodTrackersQuery.MoodType.HasValue)
            {
                query.Where(m => m.MoodType == moodTrackersQuery.MoodType);
            }

            if (moodTrackersQuery.RecordDate.HasValue)
            {
                query.Where(m => m.RecordDate == moodTrackersQuery.RecordDate);
            }

            return query;
        }
    }
}
