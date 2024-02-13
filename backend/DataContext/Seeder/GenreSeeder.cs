using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DataContext.Seeder
{
    internal class GenreSeeder : BaseSeeder
    {
        private readonly IGenreRepository _genreRepository;

        public GenreSeeder(IUnitOfWork unitOfWork, IGenreRepository genreRepository) : base(unitOfWork)
        {
            _genreRepository = genreRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Define a list of genres
                List<Genre> genres = new List<Genre>
                {
                    new Genre { Name = "Pop" },
                    new Genre { Name = "Rock" },
                    new Genre { Name = "Jazz" },
                    new Genre { Name = "Classical" },
                    new Genre { Name = "Country" },
                    new Genre { Name = "Metal" },
                    // Add more genres as needed
                };

                // Add the genres to the database
                await _genreRepository.AddRange(genres);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                throw ex;
            }
        }
    }
}
