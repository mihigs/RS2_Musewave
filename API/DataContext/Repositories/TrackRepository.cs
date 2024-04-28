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
            return await _dbContext.TrackGenres
                .Where(tg => tg.GenreId == genreId)
                .Select(tg => tg.Track)
                .ToListAsync();
        }

        public async Task<IEnumerable<Track>> GetLikedTracksAsync(string userId)
        {
            return await _dbContext.Set<Track>()
                .Where(t => t.Likes.Any(l => l.UserId == userId)) // Assuming Track has a collection of Likes
                .Include(t => t.Artist) // Adjust if your navigation property is named differently
                    .ThenInclude(a => a.User)
                .Include(t => t.TrackGenres)
                .ToListAsync();
        }

        public async Task<IEnumerable<Track>> GetTracksByNameAsync(string name)
        {
            return await _dbContext.Set<Track>()
                .Where(t => t.Title.Contains(name))
                //.Where(t => t.JamendoId is null) // Exclude Jamendo tracks from platfrom search
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .ToListAsync();
        }

        public override async Task<Track> GetById(int id)
        {
            return await _dbContext.Set<Track>()
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .Include(t => t.TrackGenres)
                .FirstOrDefaultAsync(t => t.Id == id);
        }

        public async Task<Track> GetRandomTrack(List<int> excluding)
        {
            var countQuery = _dbContext.Set<Track>().Where(t => !excluding.Contains(t.Id));
            int count = await countQuery.CountAsync();

            if (count == 0) return null;

            Random rnd = new Random();
            int skip = rnd.Next(0, count); // Get a random index to skip to.

            // Now fetch the track at that index.
            Track randomTrack = await countQuery
                .Skip(skip)
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .FirstOrDefaultAsync();

            return randomTrack;
        }


        public Task<List<Track>> GetTracksByArtistId(int artistId)
        {
            return _dbContext.Set<Track>()
                .Where(t => t.ArtistId == artistId)
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .ToListAsync();
        }

        public async Task<Track> GetByJamendoId(string jamendoId)
        {
            return _dbContext.Tracks
                .IgnoreQueryFilters()
                .Include(t => t.Artist)
                .ThenInclude(Artist => Artist.User)
                .FirstOrDefault(t => t.JamendoId.Equals(jamendoId));
        }

        public async Task<int> GetMusewaveTrackCount()
        {
            return await _dbContext.Tracks
                .Where(t => t.JamendoId == null)
                .CountAsync();
        }

        public async Task<int> GetJamendoTrackCount()
        {
            return await _dbContext.Tracks
                .Where(t => t.JamendoId != null)
                .CountAsync();
        }
    }
}
