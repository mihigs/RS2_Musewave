using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ILikeRepository : IRepository<Like>
    {
        Task<IEnumerable<Like>> GetByUserAsync(string userId);
        Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId);
    }
}
