using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IArtistRepository : IRepository<Artist>
    {
        Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
        Task<Artist> GetArtistByUserId(string userId);
        Task<int> GetArtistCount(int? month = null, int? year = null);
        Task<Artist?> GetArtistByJamendoId(string jamendoArtistId);
        Task<Artist> GetArtistDetailsAsync(int artistId);
    }
}
