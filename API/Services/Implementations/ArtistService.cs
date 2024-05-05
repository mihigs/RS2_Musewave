using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class ArtistService : IArtistService
    {
        private readonly IArtistRepository _artistRepository;
        private readonly IJamendoService _jamendoService;
        private readonly ITrackRepository _trackRepository;

        public ArtistService(IArtistRepository artistRepository, IJamendoService jamendoService, ITrackRepository trackRepository)
        {
            _artistRepository = artistRepository;
            _jamendoService = jamendoService;
            _trackRepository = trackRepository;
        }

        public async Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name)
        {
            return await _artistRepository.GetArtistsByNameAsync(name);
        }
        public async Task<ArtistDetailsDto> GetArtistDetailsAsync(int artistId, bool isJamendoArtist)
        {
            var result = new ArtistDetailsDto();

            if (isJamendoArtist)
            {
                result = await _jamendoService.GetJamendoArtistDetails(artistId.ToString());
            } else
            {
                result.Artist = await _artistRepository.GetArtistDetailsAsync(artistId);
                result.Tracks = await _trackRepository.GetTracksByArtistId(artistId);
            }

            return result;
        }

    }
}
