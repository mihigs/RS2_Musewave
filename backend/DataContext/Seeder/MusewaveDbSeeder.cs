using DataContext.Repositories;
using DataContext.Repositories.Interfaces;

namespace DataContext.Seeder
{
    public class MusewaveDbSeeder(MusewaveDbContext musewaveDbContext,
            IUnitOfWork unitOfWork,
            IUserRepository userRepository,
            IArtistRepository artistRepository)
    {
        public readonly MusewaveDbContext _musewaveDbContext = musewaveDbContext;
        public readonly IUnitOfWork _unitOfWork = unitOfWork;
        public readonly IUserRepository _userRepository = userRepository;
        public readonly IArtistRepository _artistRepository = artistRepository;
        public async Task Seed()
        {
            try
            {
                await new UserSeeder(_unitOfWork, _userRepository, _artistRepository).Seed();
                return;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }

}
