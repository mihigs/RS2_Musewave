using DataContext.Repositories.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using System.Security.Claims;
using System.Text;
using DataContext.Repositories;
using Models.Enums;

namespace Services.Implementations
{
    public class TracksService : ITracksService
    {
        private readonly ITrackRepository _trackRepository;
        private readonly IAlbumRepository _albumRepository;
        private readonly IPlaylistRepository _playlistRepository;
        private readonly ILikeRepository _likeRepository;

        public TracksService(ITrackRepository trackRespository, IAlbumRepository albumRepository, IPlaylistRepository playlistRepository, ILikeRepository likeRepository)
        {
            _trackRepository = trackRespository ?? throw new ArgumentNullException(nameof(trackRespository));
            _albumRepository = albumRepository;
            _playlistRepository = playlistRepository;
            _likeRepository = likeRepository;
        }

        public async Task<IEnumerable<Track>> GetLikedTracksAsync(string userId)
        {
            return await _trackRepository.GetLikedTracksAsync(userId);
        }

        public async Task<IEnumerable<Track>> GetTracksByNameAsync(string name)
        {
            return await _trackRepository.GetTracksByNameAsync(name);
        }
        public async Task<Track> InitializeTrack(Track track)
        {
            return await _trackRepository.Add(track);
        }
        public async Task<Track> handleListenerDoneProcessing(RabbitMqMessage messageObject)
        {
            var track = await _trackRepository.GetById(int.Parse(messageObject.TrackId));
            track.FilePath = messageObject.Payload;

            return await _trackRepository.Update(track);
        }
        public async Task<Track> GetTrackByIdAsync(int trackId, string userId)
        {
            var trackResult = await _trackRepository.GetById(trackId);
            if (trackResult == null)
            {
                throw new Exception("Track not found");
            }

            var signedUrl = GenerateSignedTrackUrl(trackResult.FilePath, trackResult.ArtistId.ToString());
            trackResult.SignedUrl = signedUrl;

            // Check if the track is liked by the user
            trackResult.IsLiked = await CheckIfTrackIsLikedByUser(trackResult.Id, userId) != null;
            return trackResult;
        }

        private string GenerateToken(string trackId, string artistId)
        {
            var claims = new List<Claim>
            {
                new Claim("trackId", trackId),
                new Claim("artistId", artistId),
                new Claim("exp", DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds().ToString())
            };
            var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("your-secret-key-needs-to-be-at-least-128-bits"));
            var creds = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256Signature);
            var token = new JwtSecurityToken(
                issuer: "Musewave",
                audience: "Musewave",
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private string GenerateSignedTrackUrl(string listenerTrackId, string artistId)
        {
            // Generate the signed URL
            var token = GenerateToken(listenerTrackId, artistId);
            //var url = $"https://localhost:7151/api/Tracks/Stream/{listenerTrackId}?token={token}";
            var url = $"{listenerTrackId}?token={token}";
            return url;
        }

        public async Task<Track> GetNextTrackAsync(int currentTrackId)
        {
            var currentTrack = await _trackRepository.GetById(currentTrackId);
            if (currentTrack == null)
            {
                throw new Exception("Current track not found");
            }

            Track nextTrack = null;
            IEnumerable<Track> tracksSameGenre = null;

            // If the current track has a genre, get tracks of the same genre
            if (currentTrack.GenreId.HasValue)
            {
                tracksSameGenre = await _trackRepository.GetTracksByGenreAsync(currentTrack.GenreId.Value);
                tracksSameGenre = tracksSameGenre.Where(x => x.Id != currentTrackId);
                if(tracksSameGenre.Count() > 0)
                {
                    nextTrack = tracksSameGenre.OrderBy(x => Guid.NewGuid()).FirstOrDefault(); // Random track with same genre
                }
            }
            // If the current track does not have a genre, return a random track
            else
            {
                nextTrack = await _trackRepository.GetRandomTrack();
            }

            if (nextTrack == null)
            {
                throw new Exception("Next track not found");
            }

            nextTrack.SignedUrl = GenerateSignedTrackUrl(nextTrack.FilePath, nextTrack.ArtistId.ToString());
            // Check if the track is liked by the user
            nextTrack.IsLiked = await CheckIfTrackIsLikedByUser(nextTrack.Id, nextTrack.Artist.User.Id) != null;
            return nextTrack;
        }

        public async Task<Track> GetNextPlaylistTrackAsync(int currentTrackId, int playlistId)
        {
            var playlist = await _playlistRepository.GetById(playlistId);
            if (playlist == null)
            {
                throw new Exception("Playlist not found");
            }

            Track track = null;
            // Get the next track in the playlist
            var playlistTracks = await _playlistRepository.GetPlaylistTracksAsync(playlistId);
            var currentTrackIndex = playlistTracks.ToList().FindIndex(x => x.Id == currentTrackId);
            if (currentTrackIndex == -1)
            {
                throw new Exception("Current track not found in playlist");
            }
            if (currentTrackIndex == playlistTracks.Count() - 1)
            {
                track = playlistTracks.FirstOrDefault();
            }
            else
            {
                track = playlistTracks.ToList()[currentTrackIndex + 1];
            }
            // Check if the track is liked by the user
            track.IsLiked = await CheckIfTrackIsLikedByUser(track.Id, track.Artist.User.Id) != null;
            return track;
        }

        public async Task<Track> GetNextAlbumTrackAsync(int currentTrackId, int albumId)
        {
            var album = await _albumRepository.GetById(albumId);
            if (album == null)
            {
                throw new Exception("Album not found");
            }

            Track track = null;
            // Get the next track in the album
            var albumTracks = await _albumRepository.GetAlbumTracksAsync(albumId);
            var currentTrackIndex = albumTracks.ToList().FindIndex(x => x.Id == currentTrackId);
            if (currentTrackIndex == -1)
            {
                throw new Exception("Current track not found in album");
            }
            if (currentTrackIndex == albumTracks.Count() - 1)
            {
                track = albumTracks.FirstOrDefault();
            }
            else
            {
                track = albumTracks.ToList()[currentTrackIndex + 1];
            }

            // Check if the track is liked by the user
            track.IsLiked = await CheckIfTrackIsLikedByUser(track.Id, track.Artist.User.Id) != null;
            return track;
        }

        public async Task<Track> GetNextTrackAsync(GetNextTrackDto getNextTrackDto)
        {
            switch (getNextTrackDto.StreamingContextType)
            {
                case StreamingContextType.RADIO:
                    return await GetNextTrackAsync(getNextTrackDto.CurrentTrackId);
                case StreamingContextType.ALBUM:
                    return await GetNextAlbumTrackAsync(getNextTrackDto.CurrentTrackId, getNextTrackDto.ContextId.Value);
                case StreamingContextType.PLAYLIST:
                    return await GetNextPlaylistTrackAsync(getNextTrackDto.CurrentTrackId, getNextTrackDto.ContextId.Value);
                default:
                    throw new ArgumentException("Invalid streaming context type");
            }
        }


        public async Task<Like> ToggleLikeTrack(int trackId, string userId)
        {
            var likedTrack = await CheckIfTrackIsLikedByUser(trackId, userId);
            if (likedTrack != null)
            {
                return await _likeRepository.Remove(likedTrack.Id);
            }
            else
            {
                return await _likeRepository.Add(new Like { TrackId = trackId, UserId = userId });
            }
        }
        
        private async Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId)
        {
            return await _likeRepository.CheckIfTrackIsLikedByUser(trackId, userId);
        }
    }
}
