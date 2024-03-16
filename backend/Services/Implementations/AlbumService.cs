using DataContext.Repositories;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class AlbumService : IAlbumService
    {
        private readonly IAlbumRepository _albumRepository;
        public AlbumService(IAlbumRepository albumRepository)
        {
            _albumRepository = albumRepository ?? throw new ArgumentNullException(nameof(albumRepository));
        }
        public async Task<IEnumerable<Album>> GetAllAlbumsAsync()
        {
            return await _albumRepository.GetAll().ConfigureAwait(false);
        }

        public async Task<Album> GetAlbumByIdAsync(int id)
        {
            return await _albumRepository.GetById(id).ConfigureAwait(false);
        }

        public async Task<Album> AddAlbumAsync(Album album)
        {
            if (album == null)
                throw new ArgumentNullException(nameof(album));

            return await _albumRepository.Add(album).ConfigureAwait(false);
        }

        public async Task<Album> UpdateAlbumAsync(Album album)
        {
            if (album == null)
                throw new ArgumentNullException(nameof(album));

            return await _albumRepository.Update(album).ConfigureAwait(false);
        }

        public async Task<Album> RemoveAlbumAsync(int id)
        {
            var album = await _albumRepository.GetById(id).ConfigureAwait(false);
            if (album != null)
            {
                _ = await _albumRepository.Remove(id);
            }
            return album;
        }

        public async Task<IEnumerable<Album>> GetAlbumsByTitleAsync(string title)
        {
            return await _albumRepository.GetAlbumsByTitleAsync(title).ConfigureAwait(false);
        }

        public async Task<IEnumerable<Track>> GetAlbumTracksAsync(int albumId)
        {
            return await _albumRepository.GetAlbumTracksAsync(albumId).ConfigureAwait(false);
        }

        public async Task<Album> GetAlbumDetails(int albumId)
        {
            return await _albumRepository.GetAlbumDetails(albumId).ConfigureAwait(false);
        }
    }
}
