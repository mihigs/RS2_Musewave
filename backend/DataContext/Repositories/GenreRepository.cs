using DataContext.Repositories.Interfaces;
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
    }
}
