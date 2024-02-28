using Models.Entities;

namespace Services.Interfaces
{
    public interface ITracksService
    {
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<Track>> GetTracksByNameAsync(string name);
    }
}
