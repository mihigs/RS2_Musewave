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
            var playlist = await _dbContext.Set<Playlist>()
                .Where(p => p.Id == playlistId)
                    .Include(p => p.User)
                .Include(p => p.Tracks)
                    .ThenInclude(pt => pt.Track)
                        .ThenInclude(t => t.Artist)
                            .ThenInclude(a => a.User)
                .FirstOrDefaultAsync();

            return playlist;
        }


        public async Task<IEnumerable<Playlist>> GetPlaylistsByUserIdAsync(string userId)
        {
            return await _dbContext.Set<Playlist>()
                .Where(p => p.UserId == userId)
                .Where(p => !p.IsExploreWeekly)
                .Include(p => p.Tracks)
                .ToListAsync();
        }

        public async Task<Playlist?> GetExploreWeeklyPlaylistAsync(string userId)
        {
            // get latest explore weekly playlist
            var exploreWeeklyPlaylist = await _dbContext.Set<Playlist>()
                .Where(p => p.UserId == userId)
                .Where(p => p.IsExploreWeekly)
                .OrderByDescending(p => p.CreatedAt)
                .FirstOrDefaultAsync();

            if (exploreWeeklyPlaylist is null)
            {
                return null;
            }

            var playlistTracks = await _dbContext.Set<PlaylistTrack>()
                .Where(pt => pt.PlaylistId == exploreWeeklyPlaylist.Id)
                .Include(pt => pt.Track)
                    .ThenInclude(t => t.TrackGenres)
                    .ThenInclude(tg => tg.Genre)
                .Include(pt => pt.Track)
                    .ThenInclude(t => t.Artist)
                        .ThenInclude(a => a.User)
                .ToListAsync();

            // Add the tracks to the playlist
            //exploreWeeklyPlaylist.Tracks = playlistTracks.ToList();
            return exploreWeeklyPlaylist;
        }

        public async Task<int> GetExploreWeeklyPlaylistId(string userId)
        {
            return await _dbContext.Set<Playlist>()
                .Where(p => p.UserId == userId)
                .Where(p => p.IsExploreWeekly)
                .OrderByDescending(p => p.CreatedAt)
                .Select(p => p.Id)
                .FirstOrDefaultAsync();
        }

        public async Task AddToPlaylistAsync(int playlistId, int trackId, string userId)
        {
            // check if the PlaylistTrack already exists
            var existingPlaylistTrack = await _dbContext.Set<PlaylistTrack>()
                .Where(pt => pt.PlaylistId == playlistId)
                .Where(pt => pt.TrackId == trackId)
                .FirstOrDefaultAsync();
            if (existingPlaylistTrack == null)
            {
                var playlistTrack = new PlaylistTrack
                {
                    PlaylistId = playlistId,
                    TrackId = trackId
                };

                await _dbContext.Set<PlaylistTrack>().AddAsync(playlistTrack);
                await _dbContext.SaveChangesAsync();
            }
        }

        public Task RemoveTrackFromPlaylistAsync(int playlistId, int trackId)

        {
            var playlistTrack = _dbContext.Set<PlaylistTrack>()
                .Where(pt => pt.PlaylistId == playlistId)
                .Where(pt => pt.TrackId == trackId)
                .FirstOrDefault();

            if (playlistTrack != null)
            {
                _dbContext.Set<PlaylistTrack>().Remove(playlistTrack);
                return _dbContext.SaveChangesAsync();
            }

            return Task.CompletedTask;
        }
    }
}
