using DataContext.Repositories.Interfaces;

namespace DataContext.Repositories
{
    public class ArtistRepository : Repository<IArtistRepository>
    {
        private readonly MusewaveDbContext _dbContext;
        public ArtistRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
