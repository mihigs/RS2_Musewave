using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface ITracksService
    {
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<Track>> GetTracksByNameAsync(string name);
        Task<Track> InitializeTrack(Track track);
        Task<Track> handleListenerDoneProcessing(RabbitMqMessage messageObject);
        Task<Track> GetTrackByIdAsync(int id);
        Task<Track> GetNextTrackAsync(int currentTrackId);
        Task<Track> GetNextPlaylistTrackAsync(int currentTrackId, int playlistId);
        Task<Track> GetNextAlbumTrackAsync(int currentTrackId, int albumId);
    }
}
