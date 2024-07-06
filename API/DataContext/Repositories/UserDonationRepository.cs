using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class UserDonationRepository : Repository<UserDonation>, IUserDonationRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public UserDonationRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

    }
}
