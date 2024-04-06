using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IPlaylistRepository : IRepository<Playlist>
    {
        Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic);
        Task<IEnumerable<Track>> GetPlaylistTracksAsync(int playlistId);
        Task<Playlist> GetPlaylistDetails(int playlistId);
        Task<IEnumerable<Playlist>> GetPlaylistsByUserIdAsync(string userId);
        Task<Playlist> GetExploreWeeklyPlaylistAsync(string userId);
    }
}
