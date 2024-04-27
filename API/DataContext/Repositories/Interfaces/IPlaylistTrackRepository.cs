using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IPlaylistTrackRepository : IRepository<PlaylistTrack>
    {
        Task AddTracksToPlaylist(int id, HashSet<Track> similarTracks);
    }
}