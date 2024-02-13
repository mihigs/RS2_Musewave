using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Repositories
{
    public class UserRepository : Repository<User>, IUserRepository
    {
        private readonly MusewaveDbContext _dbContext;
        public UserRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
