using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IArtistService
    {
        Task<ArtistDetailsDto> GetArtistDetailsAsync(int artistId, bool isJamendoArtist);
        Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
    }
}
