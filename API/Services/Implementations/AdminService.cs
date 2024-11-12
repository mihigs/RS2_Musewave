using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class AdminService : IAdminService
    {
        private readonly ITrackRepository _trackRepository;
        private readonly IUserRepository _userRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IActivityRepository _activityRepository;
        private readonly IRedisService _redisService;
        private readonly IUserDonationRepository _userDonationRepository;

        public AdminService(ITrackRepository trackRepository,
            IUserRepository userRepository,
            IArtistRepository artistRepository,
            IActivityRepository activityRepository,
            IRedisService redisService,
            IUserDonationRepository userDonationRepository
            )
        {
            _trackRepository = trackRepository ?? throw new ArgumentNullException(nameof(trackRepository));
            _userRepository = userRepository;
            _artistRepository = artistRepository;
            _activityRepository = activityRepository;
            _redisService = redisService;
            _userDonationRepository = userDonationRepository;
        }

        public async Task<AdminDashboardDetailsDto> GetDashboardDetails()
        {
            var musewaveTrackCount = await _trackRepository.GetMusewaveTrackCount();
            var jamendoTrackCount = await _trackRepository.GetJamendoTrackCount();
            var artistCount = await _artistRepository.GetArtistCount();
            var userCount = await _userRepository.GetUserCount() - artistCount;
            var dailyLoginCount = await _activityRepository.GetDailyLoginCount();
            var jamendoApiActivity = await _activityRepository.GetJamendoAPIRequestCountPerMonth();
            var totalTimeListened = await _redisService.GetAllUserTotalTimeListened();
            var allDonations = await _userDonationRepository.GetAll();
            decimal totalDonationsAmount = allDonations.Sum(x => x.Amount) / 100;
            var totalDonationsCount = allDonations.Count();

            return new AdminDashboardDetailsDto
            {
                MusewaveTrackCount = musewaveTrackCount,
                JamendoTrackCount = jamendoTrackCount,
                UserCount = userCount,
                ArtistCount = artistCount,
                DailyLoginCount = dailyLoginCount,
                JamendoApiActivity = jamendoApiActivity,
                TotalTimeListened = totalTimeListened,
                TotalDonationsAmount = totalDonationsAmount,
                TotalDonationsCount = totalDonationsCount
            };
        }
    }
}
