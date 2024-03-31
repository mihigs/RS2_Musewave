using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IListenerService
    {
        Task<BaseTrack> TrackUploadRequest(TrackUploadDetailsDto trackUploadDto);
        Task<BaseTrack> CreateTrackDatabaseEntry(TrackUploadDetailsDto trackDetails);
        Task SendToListenerForProcessing(TrackUploadDto trackUploadDto);
    }
}
