using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IListenerService
    {
        Task<Track> TrackUploadRequest(TrackUploadDetailsDto trackUploadDto);
        Task<Track> CreateTrackDatabaseEntry(TrackUploadDetailsDto trackDetails);
        Task SendToListenerForProcessing(TrackUploadDto trackUploadDto);
    }
}
