﻿using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Services.Interfaces;

namespace Services.Implementations
{
    public class AdminService : IAdminService
    {
        private readonly ITrackRepository _trackRepository;
        private readonly IUserRepository _userRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly ILoginActivityRepository _loginActivityRepository;
        private readonly IJamendoApiActivityRepository _jamendoApiActivityRepository;
        private readonly IRedisService _redisService;

        public AdminService(ITrackRepository trackRepository,
            IUserRepository userRepository,
            IArtistRepository artistRepository,
            ILoginActivityRepository loginActivityRepository,
            IJamendoApiActivityRepository jamendoApiActivityRepository,
            IRedisService redisService
            )
        {
            _trackRepository = trackRepository ?? throw new ArgumentNullException(nameof(trackRepository));
            _userRepository = userRepository;
            _artistRepository = artistRepository;
            _loginActivityRepository = loginActivityRepository;
            _jamendoApiActivityRepository = jamendoApiActivityRepository;
            _redisService = redisService;
        }

        public async Task<AdminDashboardDetailsDto> GetDashboardDetails()
        {
            var musewaveTrackCount = await _trackRepository.GetMusewaveTrackCount();
            var jamendoTrackCount = await _trackRepository.GetJamendoTrackCount();
            var artistCount = await _artistRepository.GetArtistCount();
            var userCount = await _userRepository.GetUserCount() - artistCount;
            var dailyLoginCount = await _loginActivityRepository.GetDailyLoginCount();
            var jamendoApiActivity = await _jamendoApiActivityRepository.GetJamendoAPIRequestCountPerMonth();
            var totalTimeListened = await _redisService.GetAllUserTotalTimeListened();

            return new AdminDashboardDetailsDto
            {
                MusewaveTrackCount = musewaveTrackCount,
                JamendoTrackCount = jamendoTrackCount,
                UserCount = userCount,
                ArtistCount = artistCount,
                DailyLoginCount = dailyLoginCount,
                JamendoApiActivity = jamendoApiActivity,
                TotalTimeListened = totalTimeListened
            };
        }
    }
}
