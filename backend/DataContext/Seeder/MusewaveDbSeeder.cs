using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.Configuration;

namespace DataContext.Seeder
{
    public class MusewaveDbSeeder(MusewaveDbContext musewaveDbContext,
            IUnitOfWork unitOfWork,
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
        public readonly IUnitOfWork _unitOfWork = unitOfWork;
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
                await new UserSeeder(_unitOfWork, _userRepository, _artistRepository).Seed();
                await new AlbumSeeder(_unitOfWork, _artistRepository, _albumRepository).Seed();
                await new GenreSeeder(_unitOfWork, _genreRepository).Seed();
                await new TrackSeeder(_unitOfWork, _albumRepository, _genreRepository, _trackRepository, _artistRepository, _configuration, _userRepository).Seed();
                await new PlaylistSeeder(_unitOfWork, _genreRepository, _trackRepository, _playlistRepository, _userRepository, _playlistTrackRepository).Seed();
                await new LikeSeeder(_unitOfWork, _userRepository, _trackRepository, _likeRepository).Seed();

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
