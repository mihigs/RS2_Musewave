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
        Task<Track> GetTrackByIdAsync(int trackId, string userId);
        Task<Track> GetNextTrackAsync(GetNextTrackDto getNextTrackDto, string userId);
        Task<Like?> ToggleLikeTrack(int trackId, string userId);
    }
}
