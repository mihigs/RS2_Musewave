using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Models;

namespace DataContext.Seeder
{
    internal class UserSeeder : BaseSeeder
    {
        private readonly IUserRepository _userRepository;

        public UserSeeder(IUnitOfWork unitOfWork, IUserRepository userRepository): base(unitOfWork)
        {
            _userRepository = userRepository;
        }
        public async Task<bool> Seed()
        {
            try
            {
                var hasher = new PasswordHasher<User>();
                User admin = new User
                {
                    Email = "admin@musewave.com",
                    NormalizedEmail = "ADMIN@MUSEWAVE.COM",
                    UserName = "Admin",
                    PasswordHash = hasher.HashPassword(null, "Test_123"),
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    TwoFactorEnabled = false,
                    LockoutEnabled = true,
                    AccessFailedCount = 0
                };
                List<User> casualUsers = new List<User>
                {
                    new User
                    {
                        Email = "user1@musewave.com",
                        NormalizedEmail = "USER1@MUSEWAVE.COM",
                        UserName = "user1",
                        PasswordHash = hasher.HashPassword(null, "Test_123"),
                        EmailConfirmed = true,
                        PhoneNumberConfirmed = true,
                        TwoFactorEnabled = false,
                        LockoutEnabled = true,
                        AccessFailedCount = 0
                    }
                };
                List<User> artistUsers = new List<User>
                {
                    new User
                    {
                        Email = "artist1@musewave.com",
                        NormalizedEmail = "ARTIST1@MUSEWAVE.COM",
                        UserName = "artist1",
                        PasswordHash = hasher.HashPassword(null, "Test_123"),
                        EmailConfirmed = true,
                        PhoneNumberConfirmed = true,
                        TwoFactorEnabled = false,
                        LockoutEnabled = true,
                        AccessFailedCount = 0
                    }
                };
                await _userRepository.Add(admin);
                await _userRepository.AddRange(casualUsers);
                await _userRepository.AddRange(artistUsers);

                //foreach (var user in artistUsers)
                //{
                //    _modelBuilder.Entity<Artist>().HasData(new Artist
                //    {
                //        ArtistId = user.Id,
                //        User = user
                //        //Albums = new List<Album>()
                //        //Followers = new List<Follow>(),
                //        //Following = new List<Follow>()
                //    });
                //}
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
