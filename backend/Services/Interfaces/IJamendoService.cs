using Models.Entities;
using static Models.DTOs.JamendoApiDto;

namespace Services.Interfaces
{
    public interface IJamendoService
    {
        Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName, string userId);
        Task<Track> GetTrackById(int trackId, string userId);

        Task<Track?> MapJamendoResponseToTrack(JamendoResult? response, string userId);
        JamendoApiResponse MapJamendoApiResponse(string response);
        Task<IEnumerable<Track>> CheckIfTracksAreCached(IEnumerable<Track> tracks);
        Task<IEnumerable<Track>> GetJamendoTracksPerGenres(string[] genres);
    }
}