using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Seeder
{
    internal class PlaylistSeeder : BaseSeeder
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IGenreRepository _genreRepository;
        private readonly ITrackRepository _trackRepository;
        private readonly IPlaylistRepository _playlistRepository;
        private readonly IUserRepository _userRepository;
        private readonly IPlaylistTrackRepository _playlistTrackRepository;

        public PlaylistSeeder(IUnitOfWork unitOfWork, IGenreRepository genreRepository, ITrackRepository trackRepository, IPlaylistRepository playlistRepository, IUserRepository userRepository, IPlaylistTrackRepository playlistTrackRepository) : base(unitOfWork)
        {
            _unitOfWork = unitOfWork;
            _genreRepository = genreRepository;
            _trackRepository = trackRepository;
            _playlistRepository = playlistRepository;
            _userRepository = userRepository;
            _playlistTrackRepository = playlistTrackRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Fetch all genres and users from the database
                var genres = await _genreRepository.GetAll();
                var users = await _userRepository.GetAll();

                // Create a list to hold the playlists
                List<Playlist> playlists = new List<Playlist>();

                // For each genre, create a playlist
                foreach (var genre in genres)
                {
                    // Get tracks of the same genre
                    var tracks = await _trackRepository.GetTracksByGenreAsync(genre.Id);

                    // For each user, create a playlist with a few tracks of the same genre
                    foreach (var user in users)
                    {
                        var playlist = new Playlist
                        {
                            Name = $"Best of {genre.Name} by {user.UserName}",
                            UserId = user.Id,
                            IsPublic = true
                        };

                        // Add the playlist to the database
                        await _playlistRepository.Add(playlist);
                        await _unitOfWork.SaveChangesAsync();

                        // Get the first 5 tracks
                        var playlistTracks = tracks.Take(5).Select(track => new PlaylistTrack
                        {
                            Playlist = playlist,
                            PlaylistId = playlist.Id,
                            Track = track,
                            TrackId = track.Id
                        }).ToList();

                        // Add the tracks to the playlist
                        await _playlistTrackRepository.AddRange(playlistTracks);
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                throw ex;
            }
        }

        //public async Task<bool> Seed()
        //{
        //    try
        //    {
        //        // Fetch all genres and users from the database
        //        var genres = await _genreRepository.GetAll();
        //        var users = await _userRepository.GetAll();

        //        // Create a list to hold the playlists
        //        List<Playlist> playlists = new List<Playlist>();

        //        // For each genre, create a playlist
        //        foreach (var genre in genres)
        //        {
        //            // Get tracks of the same genre
        //            var tracks = await _trackRepository.GetTracksByGenreAsync(genre.Id);

        //            // For each user, create a playlist with a few tracks of the same genre
        //            foreach (var user in users)
        //            {
        //                var playlist = new Playlist
        //                {
        //                    Name = $"Best of {genre.Name} by {user.UserName}",
        //                    UserId = user.Id,
        //                    Tracks = tracks.Take(5).ToList(), // Take the first 5 tracks
        //                    IsPublic = true
        //                };

        //                playlists.Add(playlist);
        //            }
        //        }

        //        // Add the playlists to the database
        //        await _playlistRepository.AddRange(playlists);

        //        return true;
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log error
        //        throw ex;
        //    }
        //}
    }
}
