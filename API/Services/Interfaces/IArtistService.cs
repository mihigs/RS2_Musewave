using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IArtistService
    {
        Task<IEnumerable<Artist>> GetArtistsAsync(ArtistQuery query);
        Task<ArtistDetailsDto> GetArtistDetailsAsync(int artistId, bool isJamendoArtist);
        Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
    }
}
