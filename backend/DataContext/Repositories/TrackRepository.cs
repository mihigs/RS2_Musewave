using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class TrackRepository : Repository<Track>, ITrackRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public TrackRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Track>> GetTracksByGenreAsync(int genreId)
        {
            return await _dbContext.Tracks
                .Where(t => t.GenreId == genreId)
                .ToListAsync();
        }

        public async Task<IEnumerable<Track>> GetLikedTracksAsync(string userId)
        {
            return await _dbContext.Set<Like>()
                .Where(l => l.UserId == userId)
                .Select(l => l.Track)
                .ToListAsync();
        }
    }
}
