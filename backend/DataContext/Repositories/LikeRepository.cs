using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class LikeRepository : Repository<Like>, ILikeRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public LikeRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Like>> GetByUserAsync(string userId)
        {
            return _dbContext.Set<Like>()
                .Where(l => l.UserId == userId)
                .Include(l => l.Track)
                .ThenInclude(t => t.Artist)
                .ThenInclude(a => a.User)
                .ToList();
        }
        public async Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId)
        {
            return _dbContext.Set<Like>().FirstOrDefault(l => l.TrackId == trackId && l.UserId == userId);
        }
    }
}
