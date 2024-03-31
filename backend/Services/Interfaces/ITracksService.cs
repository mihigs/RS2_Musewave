using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface ITracksService
    {
        Task<IEnumerable<BaseTrack>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<BaseTrack>> GetTracksByNameAsync(string name);
        Task<BaseTrack> InitializeTrack(BaseTrack track);
        //Task<BaseTrack> handleListenerDoneProcessing(RabbitMqMessage messageObject);
        Task<BaseTrack> GetTrackByIdAsync(int trackId, string userId);
        string GenerateSignedTrackUrl(string listenerTrackId, string artistId);
        Task<BaseTrack> GetNextTrackAsync(GetNextTrackRequestDto getNextTrackDto, string userId);
        Task<Like?> ToggleLikeTrack(int trackId, string userId);
        Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId);
        Task<List<BaseTrack>> GetTracksByArtistId(int artistId);
        Task<List<BaseTrack>> GetTracksByUserId(string userId);
    }
}
