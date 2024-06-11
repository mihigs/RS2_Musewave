using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class ArtistService : IArtistService
    {
        private readonly IArtistRepository _artistRepository;
        private readonly IJamendoService _jamendoService;
        private readonly ITrackRepository _trackRepository;
        private readonly ITracksService _tracksService;

        public ArtistService(IArtistRepository artistRepository, IJamendoService jamendoService, ITrackRepository trackRepository, ITracksService tracksService)
        {
            _artistRepository = artistRepository;
            _jamendoService = jamendoService;
            _trackRepository = trackRepository;
            _tracksService = tracksService;
        }

        public async Task<IEnumerable<Artist>> GetArtistsAsync(ArtistQuery query)
        {
            var results = new List<Artist>();

            if (!string.IsNullOrEmpty(query.Name))
            {
                var artistsByName = await GetArtistsByNameAsync(query.Name);
                results.AddRange(artistsByName);
            }

            // Remove duplicates if any
            return results.Distinct().ToList();
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
            }
            else
            {
                result.Artist = await _artistRepository.GetArtistDetailsAsync(artistId);
                result.Tracks = await _trackRepository.GetTracksByArtistId(artistId);
                result.Tracks = result.Tracks.Select(track =>
                {
                    track.SignedUrl = _tracksService.GenerateSignedTrackUrl(track.FilePath, track.ArtistId.ToString());
                    return track;
                }).ToList();

            }

            return result;
        }

    }
}
