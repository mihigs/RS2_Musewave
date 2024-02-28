using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class TracksService : ITracksService
    {
        private readonly ITrackRepository _trackRespository;

        public TracksService(ITrackRepository trackRespository)
        {
            _trackRespository = trackRespository ?? throw new ArgumentNullException(nameof(trackRespository));
        }

        public async Task<IEnumerable<Track>> GetLikedTracksAsync(string userId)
        {
            return await _trackRespository.GetLikedTracksAsync(userId);
        }

        public async Task<IEnumerable<Track>> GetTracksByNameAsync(string name)
        {
            return await _trackRespository.GetTracksByNameAsync(name);
        }
    }
}
