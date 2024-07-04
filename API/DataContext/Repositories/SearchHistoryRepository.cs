using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class SearchHistoryRepository : Repository<SearchHistory>, ISearchHistoryRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public SearchHistoryRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<SearchHistory>> GetSearchHistorysAsync(string userId)
        {
            return await _dbContext.Set<SearchHistory>()
                .Where(x => x.UserId == userId && !x.IsDeleted)
                .Include(x => x.User)
                .OrderByDescending(x => x.SearchDate)
                .ToListAsync();
        }
    }
}
