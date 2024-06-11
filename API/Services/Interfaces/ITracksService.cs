using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;

namespace Services.Interfaces
{
    public interface ITracksService
    {
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<Track>> GetTracksByNameAsync(string name);
        Task<Track> InitializeTrack(Track track);
        Task<Track> GetTrackByIdAsync(int trackId, string userId);
        string GenerateSignedTrackUrl(string listenerTrackId, string artistId);
        Task<Track> GetNextTrackAsync(GetNextTrackRequestDto getNextTrackDto, string userId);
        Task<Like?> ToggleLikeTrack(int trackId, string userId);
        Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId);
        Task<List<Track>> GetTracksByArtistId(int artistId);
        Task<List<Track>> GetTracksByUserId(string userId);
        Task<IEnumerable<Track>> GetTracksAsync(TrackQuery query);
    }
}
