using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ITrackRepository : IRepository<Track>
    {
        Task<IEnumerable<Track>> GetTracksByGenreAsync(int genreId);
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<Track>> GetTracksByNameAsync(string name);
        Task<Track> GetRandomTrack(List<int> excluding);
        Task<List<Track>> GetTracksByArtistId(int artistId);
    }
}
