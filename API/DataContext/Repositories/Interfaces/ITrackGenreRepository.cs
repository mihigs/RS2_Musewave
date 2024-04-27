using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ITrackGenreRepository : IRepository<TrackGenre>
    {
        Task<IEnumerable<Genre>> GetGenresByTrackId(int id);
    }
}
