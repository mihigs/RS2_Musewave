using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class UserRepository : Repository<User>, IUserRepository
    {
        private const string musewaveAdminEmail = "admin@musewave.com";
        private readonly MusewaveDbContext _dbContext;
        public UserRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<User> GetAdminUser()
        {
            return await _dbContext.Set<User>()
                .FirstOrDefaultAsync(u => u.Email == musewaveAdminEmail);
        }

        public async Task<User> GetUserById(string id)
        {
            return await _dbContext.Set<User>()
                .Include(u => u.Language)
                .FirstOrDefaultAsync(u => u.Id == id);
        }

        public async Task<User> GetUserByName(string name)
        {
            return await _dbContext.Set<User>()
                .FirstOrDefaultAsync(u => u.UserName == name);
        }

        public async Task<int> GetUserCount(bool withArtists = true, int? month = null, int? year = null)
        {
            return await _dbContext.Set<User>()
                .Where(u =>
                    (month == null || u.JoinDate.Month == month.Value) &&
                    (year == null || u.JoinDate.Year == year.Value) &&
                    (withArtists || u.ArtistId == null))
                .CountAsync();
        }

    }
}
