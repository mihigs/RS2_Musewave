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
                .Include(pt => pt.Track)
                    .ThenInclude(t => t.Artist)
                        .ThenInclude(a => a.User)
                .Where(pt => pt.PlaylistId == playlistId)
                .Select(pt => pt.Track)
                .ToListAsync();
        }

        public async Task<Playlist> GetPlaylistDetails(int playlistId)
        {
            var playlistTracks = await _dbContext.Set<PlaylistTrack>()
                .Where(pt => pt.PlaylistId == playlistId)
                .Include(pt => pt.Track)
                .ThenInclude(t => t.Artist)
                .ThenInclude(a => a.User)
                .ToListAsync();

            // Get the playlist
            var playlist = await _dbContext.Set<Playlist>()
                .Where(p => p.Id == playlistId)
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == playlistId);

            // Add the tracks to the playlist
            playlist.Tracks = playlistTracks.Select(pt => pt.Track).ToList();
            return playlist;
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByUserIdAsync(string userId)
        {
            return await _dbContext.Set<Playlist>()
                .Where(p => p.UserId == userId)
                .ToListAsync();
        }
    }
}
