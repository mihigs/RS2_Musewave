using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class PlaylistService : IPlaylistService
    {
        private readonly IPlaylistRepository _playlistRepository;
        private readonly ITracksService _tracksService;
        private readonly ILikeRepository _likeRepository;
        private readonly IExploreWeeklyGenerator _exploreWeeklyGenerator;

        public PlaylistService(IPlaylistRepository playlistRepository, ITracksService tracksService, ILikeRepository likeRepository, IExploreWeeklyGenerator exploreWeeklyGenerator)
        {
            _playlistRepository = playlistRepository ?? throw new ArgumentNullException(nameof(playlistRepository));
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
            _likeRepository = likeRepository;
            _exploreWeeklyGenerator = exploreWeeklyGenerator;
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsAsync(PlaylistQuery query)
        {
            var results = new List<Playlist>();

            if (!string.IsNullOrEmpty(query.Name))
            {
                var playlistsByName = await GetPlaylistsByNameAsync(query.Name, query.ArePublic.GetValueOrDefault(true));
                results.AddRange(playlistsByName);
            }

            // Remove duplicates if any
            return results.Distinct().ToList();
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true)
        {
            return await _playlistRepository.GetPlaylistsByNameAsync(name, arePublic);
        }

        public async Task<Playlist> GetPlaylistDetailsAsync(int id, string userId)
        {
            var playlistDetails = await _playlistRepository.GetPlaylistDetails(id);
            if (playlistDetails == null)
            {
                return null;
            }
            // add the SignedUrl to each track in the playlist
            foreach (var playlistTrack in playlistDetails.Tracks)
            {
                if (playlistTrack.Track.JamendoId == null)
                {
                    playlistTrack.Track.SignedUrl = _tracksService.GenerateSignedTrackUrl(playlistTrack.Track.FilePath, playlistTrack.Track.ArtistId.ToString());
                }
                playlistTrack.Track.IsLiked = await _tracksService.CheckIfTrackIsLikedByUser(playlistTrack.Track.Id, userId) != null;
            }
            return playlistDetails;
        }

        public async Task<IEnumerable<UserPlaylistsDto>> GetPlaylistsByUserIdAsync(string userId)
        {
            var playlists = await _playlistRepository.GetPlaylistsByUserIdAsync(userId);
            return playlists.Select(p => new UserPlaylistsDto(p)).ToList();
        }

        public async Task<Playlist> GetExploreWeeklyPlaylistAsync(string userId)
        {
            var exploreWeeklyPlaylist = await _playlistRepository.GetExploreWeeklyPlaylistAsync(userId);
            if (exploreWeeklyPlaylist == null)
            {
                exploreWeeklyPlaylist = await _exploreWeeklyGenerator.GenerateExploreWeeklyPlaylistForUser(userId);

                if (exploreWeeklyPlaylist == null)
                {
                    exploreWeeklyPlaylist = await _playlistRepository.GetExploreWeeklyPlaylistAsync(userId);
                }
            }
            return exploreWeeklyPlaylist;
        }

        public async Task<Playlist> GetLikedPlaylistAsync(string userId)
        {
            var likedTracks = await _likeRepository.GetByUserAsync(userId);
            var playlist = new Playlist
            {
                UserId = userId,
                Name = "Liked tracks",
                Tracks = likedTracks.Select(l =>
                {
                    l.Track.IsLiked = true; // Set the IsLiked property to true directly on the Track entity
                    if (l.Track.JamendoId == null)
                    {
                        l.Track.SignedUrl = _tracksService.GenerateSignedTrackUrl(l.Track.FilePath, l.Track.ArtistId.ToString());
                    }
                    return new PlaylistTrack
                    {
                        Track = l.Track
                    };
                }).ToList(),
                IsPublic = false,
                IsExploreWeekly = false
            };
            return playlist;
        }

        public async Task CreatePlaylistAsync(Playlist playlist)
        {
            await _playlistRepository.Add(playlist);
        }

        public async Task AddToPlaylistAsync(TogglePlaylistTrackDto addToPlaylistDto, string userId)
        {
            var playlist = await _playlistRepository.GetPlaylistDetails(addToPlaylistDto.PlaylistId);
            if (playlist == null)
            {
                throw new KeyNotFoundException("Playlist not found");
            }
            else if (playlist.UserId != userId)
            {
                throw new UnauthorizedAccessException("You are not the owner of the playlist");
            }
            await _playlistRepository.AddToPlaylistAsync(addToPlaylistDto.PlaylistId, addToPlaylistDto.TrackId, userId);
        }

        public async Task RemoveTrackFromPlaylistAsync(int playlistId, int trackId, string userId)
        {
            var playlist = await _playlistRepository.GetPlaylistDetails(playlistId);
            if (playlist == null)
            {
                throw new KeyNotFoundException("Playlist not found");
            }
            else if (playlist.UserId != userId)
            {
                throw new UnauthorizedAccessException("You are not the owner of the playlist");
            }

            await _playlistRepository.RemoveTrackFromPlaylistAsync(playlistId, trackId);
        }

        public async Task UpdatePlaylistAsync(PlaylistUpdateDto playlistUpdateDto, string userId)
        {
            var playlist = await _playlistRepository.GetPlaylistDetails(playlistUpdateDto.Id);
            if (playlist == null)
            {
                throw new KeyNotFoundException("Playlist not found");
            }
            else if (playlist.UserId != userId)
            {
                throw new UnauthorizedAccessException("You are not the owner of the playlist");
            }

            playlist.Name = playlistUpdateDto.Name;
            playlist.IsPublic = playlistUpdateDto.IsPublic;
            await _playlistRepository.Update(playlist);
        }

        public async Task RemovePlaylistAsync(int playlistId, string userId)
        {
            var playlist = await _playlistRepository.GetPlaylistDetails(playlistId);
            if (playlist == null)
            {
                throw new KeyNotFoundException("Playlist not found");
            }
            else if (playlist.UserId != userId)
            {
                throw new UnauthorizedAccessException("You are not the owner of the playlist");
            }

            playlist.IsDeleted = true;

            await _playlistRepository.Update(playlist);
        }
    }
}
