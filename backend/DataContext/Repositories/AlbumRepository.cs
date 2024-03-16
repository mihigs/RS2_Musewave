using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class AlbumRepository : Repository<Album>, IAlbumRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public AlbumRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Album>> GetAlbumsByTitleAsync(string title)
        {
            return await _dbContext.Set<Album>()
                .Where(g => g.Title.Contains(title))
                .Include(a => a.Artist)
                .ThenInclude(Artist => Artist.User)
                .ToListAsync();
        }

        public async Task<IEnumerable<Track>> GetAlbumTracksAsync(int albumId)
        {
            return await _dbContext.Set<Album>()
                .Where(t => t.Id == albumId)
                .Include(t => t.Tracks)
                .SelectMany(t => t.Tracks)
                .ToListAsync();
        }

        public async Task<Album> GetAlbumDetails(int albumId)
        {
            return await _dbContext.Set<Album>()
                .Where(a => a.Id == albumId)
                .Include(a => a.Artist)
                .ThenInclude(Artist => Artist.User)
                .Include(a => a.Tracks)
                .FirstOrDefaultAsync(a => a.Id == albumId);
        }
    }
}
