using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IGenreRepository : IRepository<Genre>
    {
        Task<IEnumerable<Genre>> GetGenresByNameAsync(string name);
    }
}
