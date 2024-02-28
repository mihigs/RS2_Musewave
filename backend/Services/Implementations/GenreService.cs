using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class GenreService : IGenreService
    {
        private readonly IGenreRepository _genreRepository;

        public GenreService(IGenreRepository genreRepository)
        {
            _genreRepository = genreRepository ?? throw new ArgumentNullException(nameof(genreRepository));
        }

        public async Task<IEnumerable<Genre>> GetGenresByName (string name)
        {
            return await _genreRepository.GetGenresByNameAsync(name);
        }
    }
}
