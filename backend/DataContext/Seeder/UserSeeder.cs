﻿using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Models.Entities;
using System.Collections.ObjectModel;

namespace DataContext.Seeder
{
    internal class UserSeeder : BaseSeeder
    {
        private readonly IUserRepository _userRepository;
        private readonly IArtistRepository _artistRepository;

        public UserSeeder(IUnitOfWork unitOfWork, IUserRepository userRepository, IArtistRepository artistRepository): base(unitOfWork)
        {
            _userRepository = userRepository;
            _artistRepository = artistRepository;
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
                    AccessFailedCount = 0,
                    Likes = null
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
                        AccessFailedCount = 0,
                        Likes = null
                    }
                };
                List<User> artistUsers = new List<User>
                {
                    new User
                    {
                        Email = "artist@musewave.com",
                        NormalizedEmail = "artist@MUSEWAVE.COM",
                        UserName = "Musewave",
                        PasswordHash = hasher.HashPassword(null, "Test_123"),
                        EmailConfirmed = true,
                        PhoneNumberConfirmed = true,
                        TwoFactorEnabled = false,
                        LockoutEnabled = true,
                        AccessFailedCount = 0,
                        Likes = null
                    }
                };

                Collection<User> users = [admin, ..casualUsers, ..artistUsers];
                await _userRepository.AddRange(users);

                List<Artist> artists = new List<Artist>();
                foreach (var artist in artistUsers)
                {

                    artists.Add(new Artist
                    {
                        UserId = artist.Id,
                        User = artist
                    });
                }
                await _artistRepository.AddRange(artists);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"UserSeeder failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
