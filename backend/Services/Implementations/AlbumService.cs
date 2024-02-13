using DataContext.Repositories;
using Models.Entities;

namespace Services.Implementations
{
    public class AlbumService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAlbumRepository _albumRepository;
        public AlbumService(IUnitOfWork unitOfWork, IAlbumRepository albumRepository)
        {
            _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
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
                await _unitOfWork.SaveChangesAsync().ConfigureAwait(false);
            }
            return album;
        }
    }
}
