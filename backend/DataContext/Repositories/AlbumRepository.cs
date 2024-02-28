using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class AlbumRepository : Repository<Album>, IAlbumRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public AlbumRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Album>> GetAlbumsByTitleAsync(string title)
        {
            return await _dbContext.Set<Album>()
                .Where(g => g.Title.Contains(title))
                .ToListAsync();
        }
    }
}
