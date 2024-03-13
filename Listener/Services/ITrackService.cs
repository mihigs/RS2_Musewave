
using Listener.Models.DTOs;

namespace Listener.Services
{
    public interface ITrackService
    {
        Task ProcessTrack(TrackUploadDto model);
    }
}