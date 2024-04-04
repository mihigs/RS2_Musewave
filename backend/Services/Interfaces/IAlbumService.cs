using Models.Entities;

namespace Services.Interfaces
{
    public interface IAlbumService
    {
        Task<IEnumerable<Album>> GetAllAlbumsAsync();
        Task<Album> GetAlbumByIdAsync(int id);
        Task<Album> AddAlbumAsync(Album album);
        Task<Album> UpdateAlbumAsync(Album album);
        Task<Album> RemoveAlbumAsync(int id);
        Task<IEnumerable<Album>> GetAlbumsByTitleAsync(string title);
        Task<IEnumerable<Track>> GetAlbumTracksAsync(int albumId);
        Task<Album> GetAlbumDetails(int albumId, string userId);
    }
}
