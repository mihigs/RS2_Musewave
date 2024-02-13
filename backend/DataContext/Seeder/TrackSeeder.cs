using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Models;

namespace DataContext.Seeder
{
    internal class TrackSeeder : BaseSeeder
    {
        private readonly IUserRepository _userRepository;
        private readonly IArtistRepository _artistRepository;

        public TrackSeeder(IUnitOfWork unitOfWork, IUserRepository userRepository, IArtistRepository artistRepository): base(unitOfWork)
        {
            _userRepository = userRepository;
            _artistRepository = artistRepository;
        }
        public async Task<bool> Seed()
        {
            try
            {
                

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                throw ex;
            }
        }
    }
}
