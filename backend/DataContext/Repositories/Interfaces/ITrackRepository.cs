using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ITrackRepository : IRepository<Track>
    {
        Task<IEnumerable<Track>> GetTracksByGenreAsync(int genreId);
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
    }
}
