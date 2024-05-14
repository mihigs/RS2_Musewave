using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IGenreRepository : IRepository<Genre>
    {
        Task<List<Genre>> GetGenresByNameAsync(string name);
        Task<List<Genre>> GetGenresByIdsAsync(List<int> ids);
    }
}
