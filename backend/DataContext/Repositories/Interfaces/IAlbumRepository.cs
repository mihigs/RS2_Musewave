using Models.Entities;

namespace DataContext.Repositories;
public interface IAlbumRepository : IRepository<Album>
{
    Task<IEnumerable<Album>> GetAlbumsByTitleAsync(string title);
    Task<IEnumerable<Track>> GetAlbumTracksAsync(int albumId);
}