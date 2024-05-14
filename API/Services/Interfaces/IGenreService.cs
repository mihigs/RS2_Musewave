using Genre = Models.Entities.Genre;

namespace Services.Interfaces
{
    public interface IGenreService
    {
        Task<IEnumerable<Genre>> GetGenresByName(string name);
    }
}
