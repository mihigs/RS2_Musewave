using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class GenreRepository : Repository<Genre>, IGenreRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public GenreRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Genre>> GetGenresByNameAsync(string name)
        {
            return await _dbContext.Set<Genre>()
                .Where(g => g.Name.Contains(name))
                .ToListAsync();
        }
    }
}
