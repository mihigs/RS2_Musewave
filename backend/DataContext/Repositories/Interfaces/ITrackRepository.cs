using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ITrackRepository : IRepository<BaseTrack>
    {
        Task<IEnumerable<BaseTrack>> GetTracksByGenreAsync(int genreId);
        Task<IEnumerable<BaseTrack>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<BaseTrack>> GetTracksByNameAsync(string name);
        Task<BaseTrack> GetRandomTrack(List<int> excluding);
        Task<List<BaseTrack>> GetTracksByArtistId(int artistId);
    }
}
