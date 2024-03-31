using Models.Entities;
using static Models.DTOs.JamendoApiDto;

namespace Services.Interfaces
{
    public interface IJamendoService
    {
        Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName);
        Task<Track> GetTrackById(int trackId);

        Track MapJamendoResponseToTrack(JamendoResult response);
        JamendoApiResponse MapJamendoApiResponse(string response);

    }
}