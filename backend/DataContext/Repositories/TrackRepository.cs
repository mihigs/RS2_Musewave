using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class TrackRepository : Repository<BaseTrack>, ITrackRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public TrackRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<BaseTrack>> GetTracksByGenreAsync(int genreId)
        {
            return await _dbContext.TrackGenres
                .Where(tg => tg.GenreId == genreId)
                .Select(tg => tg.Track)
                .ToListAsync();
        }

        public async Task<IEnumerable<BaseTrack>> GetLikedTracksAsync(string userId)
        {
            return await _dbContext.Set<Like>()
                .Where(l => l.UserId == userId)
                .Select(l => l.Track)
                .ToListAsync();
        }

        public async Task<IEnumerable<BaseTrack>> GetTracksByNameAsync(string name)
        {
            return await _dbContext.Set<BaseTrack>()
                .Where(t => t.Title.Contains(name))
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .ToListAsync();
        }

        public async Task<BaseTrack> GetById(int id)
        {
            return await _dbContext.Set<BaseTrack>()
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .FirstOrDefaultAsync(t => t.Id == id);
        }

        public async Task<BaseTrack> GetRandomTrack(List<int> excluding)
        {
            return await _dbContext.Set<BaseTrack>()
                .Where(t => !excluding.Contains(t.Id))
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .OrderBy(t => Guid.NewGuid())
                .FirstOrDefaultAsync();
        }

        public Task<List<BaseTrack>> GetTracksByArtistId(int artistId)
        {
            return _dbContext.Set<BaseTrack>()
                .Where(t => t.ArtistId == artistId)
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .ToListAsync();
        }
    }
}
