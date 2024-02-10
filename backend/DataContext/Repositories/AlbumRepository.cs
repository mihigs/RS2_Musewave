using Microsoft.EntityFrameworkCore;
using Models;

namespace DataContext.Repositories
{
    public class AlbumRepository : IAlbumRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public AlbumRepository(MusewaveDbContext dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
        public async Task<IEnumerable<Album>> GetAll()
        {
            return await _dbContext.Albums.ToListAsync().ConfigureAwait(false);
        }

        public async Task<Album> GetById(int id)
        {
            return await GetById(id).ConfigureAwait(false);
        }

        public async Task<Album> Add(Album entity)
        {
            await Add(entity).ConfigureAwait(false);
            return entity;
        }

        public async Task<Album> Update(Album entity)
        {
            await Update(entity).ConfigureAwait(false);
            return entity;
        }

        public async Task<Album> Remove(int id)
        {
            var album = await GetById(id).ConfigureAwait(false);
            if (album != null)
            {
                _dbContext.Albums.Remove(album);
                await _dbContext.SaveChangesAsync().ConfigureAwait(false);
            }
            return album;
        }
        public Task<IEnumerable<Album>> AddRange(IEnumerable<Album> entities)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Album>> UpdateRange(IEnumerable<Album> entities)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Album>> RemoveRange(IEnumerable<Album> entities)
        {
            throw new NotImplementedException();
        }
    }
}
