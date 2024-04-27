using Models.Entities;

namespace Services.Interfaces
{
    public interface IArtistService
    {
        Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
    }
}
