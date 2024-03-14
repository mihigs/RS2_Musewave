
using Listener.Models.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Listener.Services
{
    public interface ITrackService
    {
        Task StoreTrack(TrackUploadDto model);
        Task<FileStreamResult> HandleTrackStreamRequest(string trackId, string artistId, string range);
    }
}