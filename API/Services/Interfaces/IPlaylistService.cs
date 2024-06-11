using Models.DTOs;
using Models.DTOs.Queries;
using Playlist = Models.Entities.Playlist;

namespace Services.Interfaces
{
    public interface IPlaylistService
    {
        Task<IEnumerable<Playlist>> GetPlaylistsAsync(PlaylistQuery query);
        Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true);
        Task<Playlist> GetPlaylistDetailsAsync(int id, string userId);
        Task<IEnumerable<UserPlaylistsDto>> GetPlaylistsByUserIdAsync(string userId);
        Task<Playlist> GetExploreWeeklyPlaylistAsync(string userId);
        Task<Playlist> GetLikedPlaylistAsync(string userId);
        Task AddToPlaylistAsync(TogglePlaylistTrackDto addToPlaylistDto, string userId);
        Task CreatePlaylistAsync(Playlist playlist);
        Task RemoveTrackFromPlaylistAsync(int playlistId, int trackId, string userId);
    }
}
