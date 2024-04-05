using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class TrackGenreRepository : Repository<TrackGenre>, ITrackGenreRepository
    {
        private readonly MusewaveDbContext _dbContext;
        public TrackGenreRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
        public async Task<IEnumerable<Genre>> GetGenresByTrackId(int id)
        {
            return await _dbContext.Set<TrackGenre>()
                .Where(tg => tg.TrackId == id)
                .Select(tg => tg.Genre)
                .ToListAsync();
        }

    }
}
