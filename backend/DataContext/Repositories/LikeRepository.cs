using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Repositories
{
    public class LikeRepository : Repository<Like>, ILikeRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public LikeRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
