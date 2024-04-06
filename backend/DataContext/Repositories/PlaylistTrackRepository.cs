using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class PlaylistTrackRepository : Repository<PlaylistTrack>, IPlaylistTrackRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public PlaylistTrackRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task AddTracksToPlaylist(int id, HashSet<Track> similarTracks)
        {
            // check if the playlist exists
            var playlist = await _dbContext.Set<Playlist>().FirstOrDefaultAsync(p => p.Id == id);
            if (playlist == null)
            {
                throw new ArgumentException("Playlist not found");
            }
            // add the tracks to the playlist


        }
    }
}
