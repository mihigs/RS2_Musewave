using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using static Models.DTOs.JamendoApiDto;

namespace Services.Interfaces
{
    public interface IJamendoService
    {
        Task<IEnumerable<Track>> GetJamendoTracksAsync(JamendoTrackQuery query, string userId);
        Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName, string userId);
        Task<Track> GetTrackById(int trackId, string userId);

        Task<Track?> MapJamendoResponseToTrack(JamendoTrackResult? response, string? userId, int? artistId);
        JamendoApiResponse<JamendoTrackResult> MapJamendoApiTrackResponse(string response);
        JamendoApiResponse<JamendoArtistDetailsResult> MapJamendoApiArtistResponse(string response);
        Task<IEnumerable<Track>> CheckIfTracksAreCached(IEnumerable<Track> tracks);
        Task<IEnumerable<Track>> GetJamendoTracksPerGenres(string[] genres);
        Task<IEnumerable<Track>> GetPopularJamendoTracks();
        Task<ArtistDetailsDto> GetJamendoArtistDetails(string jamendoArtistId);

    }
}