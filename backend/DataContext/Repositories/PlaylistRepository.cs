using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class PlaylistRepository : Repository<Playlist>, IPlaylistRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public PlaylistRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true)
        {
            return await _dbContext.Set<Playlist>()
                .Where(g => g.Name.Contains(name))
                .Where(g => g.IsPublic == arePublic)
                .ToListAsync();
        }

        public async Task<IEnumerable<Track>> GetPlaylistTracksAsync(int playlistId)
        {
            return await _dbContext.Set<PlaylistTrack>()
                .Where(pt => pt.PlaylistId == playlistId)
                .Select(pt => pt.Track)
                .ToListAsync();
        }
    }
}
