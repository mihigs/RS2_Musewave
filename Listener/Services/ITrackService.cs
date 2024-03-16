
using Listener.Models.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Listener.Services
{
    public interface ITrackService
    {
        Task StoreTrack(TrackUploadDto model);
        Task<(Stream, string, long, long, long, string)> HandleTrackStreamRequest(string trackId, string artistId, string range = null);
    }
}