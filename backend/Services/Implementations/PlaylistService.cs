using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class PlaylistService : IPlaylistService
    {
        private readonly IPlaylistRepository _playlistRepository;
        private readonly ITracksService _tracksService;

        public PlaylistService(IPlaylistRepository playlistRepository, ITracksService tracksService)
        {
            _playlistRepository = playlistRepository ?? throw new ArgumentNullException(nameof(playlistRepository));
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true)
        {
            return await _playlistRepository.GetPlaylistsByNameAsync(name, arePublic);
        }

        public async Task<Playlist> GetPlaylistDetailsAsync(int id, string userId)
        {
            var playlistDetails = await _playlistRepository.GetPlaylistDetails(id);
            // add the SignedUrl to each track in the playlist
            foreach (var track in playlistDetails.Tracks)
            {
                track.SignedUrl = _tracksService.GenerateSignedTrackUrl(track.FilePath, track.ArtistId.ToString());
                track.IsLiked = await _tracksService.CheckIfTrackIsLikedByUser(track.Id, userId) != null;
            }
            return await _playlistRepository.GetPlaylistDetails(id);
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByUserIdAsync(string userId)
        {
            return await _playlistRepository.GetPlaylistsByUserIdAsync(userId);
        }
    }
}
