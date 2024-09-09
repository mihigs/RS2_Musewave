using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Models.Entities;

namespace DataContext.Seeder
{
    public class MusewaveDbSeeder(MusewaveDbContext musewaveDbContext,
            RoleManager<IdentityRole> roleManager,
            UserManager<User> userManager,
            ILanguageRepository languageRepository,
            IUserRepository userRepository,
            IArtistRepository artistRepository,
            IPlaylistRepository playlistRepository,
            IAlbumRepository albumRepository,
            ITrackRepository trackRepository,
            IGenreRepository genreRepository,
            ILikeRepository likeRepository,
            IPlaylistTrackRepository playlistTrackRepository,
            IConfiguration configuration
            )
    {
        public readonly MusewaveDbContext _musewaveDbContext = musewaveDbContext;
        public readonly RoleManager<IdentityRole> _roleManager = roleManager;
        public readonly UserManager<User> _userManager = userManager;
        public readonly ILanguageRepository _languageRepository = languageRepository;
        public readonly IUserRepository _userRepository = userRepository;
        public readonly IArtistRepository _artistRepository = artistRepository;
        public readonly IPlaylistRepository _playlistRepository = playlistRepository;
        public readonly IAlbumRepository _albumRepository = albumRepository;
        public readonly ITrackRepository _trackRepository = trackRepository;
        public readonly IGenreRepository _genreRepository = genreRepository;
        public readonly ILikeRepository _likeRepository = likeRepository;
        public readonly IPlaylistTrackRepository _playlistTrackRepository = playlistTrackRepository;
        public readonly IConfiguration _configuration = configuration;

        public async Task Seed()
        {
            try
            {
                await new LanguageSeeder(_languageRepository).Seed();
                await new RoleSeeder(_roleManager).Seed();
                await new UserSeeder(_userManager, _userRepository, _artistRepository).Seed();
                await new AlbumSeeder(_artistRepository, _albumRepository).Seed();
                await new GenreSeeder(_genreRepository).Seed();
                await new TrackSeeder(_albumRepository, _genreRepository, _trackRepository, _artistRepository, _configuration, _userRepository).Seed();
                await new LikeSeeder(_userRepository, _trackRepository, _likeRepository).Seed();
                await new PlaylistSeeder(_genreRepository, _trackRepository, _playlistRepository, _userRepository, _playlistTrackRepository).Seed();

                return;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                throw new Exception(ex.Message);
            }
        }

    }

}
