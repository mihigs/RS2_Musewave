using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class ArtistService : IArtistService
    {
        private readonly IArtistRepository _artistRepository;

        public ArtistService(IArtistRepository artistRepository)
        {
            _artistRepository = artistRepository;
        }

        public async Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name)
        {
            return await _artistRepository.GetArtistsByNameAsync(name);
        }
    }
}
