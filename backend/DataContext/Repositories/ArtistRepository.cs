using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class ArtistRepository : Repository<Artist>, IArtistRepository
    {
        private readonly MusewaveDbContext _dbContext;
        public ArtistRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name)
        {
            return await _dbContext.Set<Artist>()
                .Where(a => a.User.UserName.Contains(name))
                .Include(a => a.User)
                .ToListAsync();
        }

        public Task<Artist> GetArtistByUserIdAsync(string userId)
        {
            return _dbContext.Set<Artist>()
                .Include(a => a.User)
                .FirstOrDefaultAsync(a => a.UserId == userId);
        }
    }
}
