using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Repositories
{
    public class LanguageRepository : Repository<Language>, ILanguageRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public LanguageRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
