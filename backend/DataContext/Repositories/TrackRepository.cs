using Models.Entities;

namespace DataContext.Repositories
{
    public class TrackRepository : Repository<Track>
    {
        private readonly MusewaveDbContext _dbContext;

        public TrackRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
