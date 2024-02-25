using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace Services.Implementations
{
    public class TracksService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITrackRepository _trackRespository;

        public TracksService(IUnitOfWork unitOfWork, ITrackRepository trackRespository)
        {
            _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
            _trackRespository = trackRespository ?? throw new ArgumentNullException(nameof(trackRespository));
        }

        public async Task<IEnumerable<Track>> GetLikedTracksAsync()
        {
            return await _trackRespository.GetLikedTracksAsync(_unitOfWork.GetCurrentUserId());
        }
    }
}
