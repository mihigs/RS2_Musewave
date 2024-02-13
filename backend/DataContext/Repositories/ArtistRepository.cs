using DataContext.Repositories.Interfaces;
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
    }
}
