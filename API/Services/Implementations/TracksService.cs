using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.IdentityModel.Tokens;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Models.Enums;
using Services.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Services.Implementations
{
    public class TracksService : ITracksService
    {
        private readonly ITrackRepository _trackRepository;
        private readonly IAlbumRepository _albumRepository;
        private readonly IPlaylistRepository _playlistRepository;
        private readonly ILikeRepository _likeRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IJamendoService _jamendoService;
        private readonly IRedisService _redisService;

        public TracksService(
            ITrackRepository trackRespository,
            IAlbumRepository albumRepository,
            IPlaylistRepository playlistRepository,
            ILikeRepository likeRepository,
            IArtistRepository artistRepository,
            IJamendoService jamendoService,
            IRedisService redisService
        )
        {
            _trackRepository = trackRespository ?? throw new ArgumentNullException(nameof(trackRespository));
            _albumRepository = albumRepository;
            _playlistRepository = playlistRepository;
            _likeRepository = likeRepository;
            _artistRepository = artistRepository;
            _jamendoService = jamendoService;
            _redisService = redisService;
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
        public async Task<Track> GetTrackByIdAsync(int trackId, string userId)
        {
            var trackResult = await _trackRepository.GetById(trackId);
            if (trackResult is null)
            {
                throw new Exception("Track not found");
            }
            if (trackResult.FilePath is null && trackResult.JamendoId is null)
            {
                throw new Exception("Track is not processed yet");
            }
            if (trackResult.JamendoId is null)
            {
                var signedUrl = GenerateSignedTrackUrl(trackResult.FilePath, trackResult.ArtistId.ToString());
                trackResult.SignedUrl = signedUrl;
            }
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

        public string GenerateSignedTrackUrl(string listenerTrackId, string artistId)
        {
            var token = GenerateToken(listenerTrackId, artistId);
            var url = $"{listenerTrackId}?token={token}";
            return url;
        }

        public async Task<Track> GetNextTrackAsync(int currentTrackId, string userId, List<int> trackHistoryIds)
        {
            var currentTrack = await _trackRepository.GetById(currentTrackId);
            if (currentTrack is null)
            {
                throw new Exception("Current track not found");
            }

            Track nextTrack = null;
            IEnumerable<Track> tracksSameGenre = null;

            // If the current track has a genre, get tracks of the same genre
            if (currentTrack.TrackGenres.Count > 0)
            {
                tracksSameGenre = await _trackRepository.GetTracksByGenreAsync(currentTrack.TrackGenres.First().GenreId);
                // remove tracks that are in the track history
                tracksSameGenre = tracksSameGenre.Where(x => !trackHistoryIds.Contains(x.Id));
                tracksSameGenre = tracksSameGenre.Where(x => x.Id != currentTrackId);
                if (tracksSameGenre.Count() > 0)
                {
                    nextTrack = tracksSameGenre.OrderBy(x => Guid.NewGuid()).FirstOrDefault(); // Random track with same genre
                }
            }

            if (nextTrack is null)
            {
                // If there are no tracks of the same genre, get a random track
                // If all tracks have been played, start over
                nextTrack = await _trackRepository.GetRandomTrack(excluding: trackHistoryIds) ?? await _trackRepository.GetRandomTrack(excluding: []);
            }
            nextTrack = await _trackRepository.GetById(nextTrack.Id);
            return nextTrack;
        }

        public async Task<Track> GetNextPlaylistTrackAsync(int currentTrackId, int playlistId)
        {
            var playlist = await _playlistRepository.GetById(playlistId);
            if (playlist is null)
            {
                throw new Exception("Playlist not found");
            }

            Track track = null;
            // Get the next track in the playlist
            var playlistTracks = await _playlistRepository.GetPlaylistTracksAsync(playlistId);
            List<Track> playlistTracksList = playlistTracks.ToList();
            var currentTrackIndex = playlistTracksList.FindIndex(x => x.Id == currentTrackId);
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
                track = playlistTracksList[currentTrackIndex + 1];
            }
            return track;
        }

        public async Task<Track> GetNextAlbumTrackAsync(int currentTrackId, int albumId)
        {
            var album = await _albumRepository.GetById(albumId);
            if (album is null)
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

            return track;
        }

        public async Task<Track> GetNextTrackAsync(GetNextTrackRequestDto getNextTrackDto, string userId)
        {
            // Add time listened to redis
            await _redisService.AddTotalTimeListened(userId, getNextTrackDto.TimeListened);

            var nextTrack = new Track();
            switch (getNextTrackDto.StreamingContextType)
            {
                case StreamingContextType.RADIO:
                    nextTrack = await GetNextTrackAsync(getNextTrackDto.CurrentTrackId, userId, getNextTrackDto.TrackHistoryIds);
                    break;
                case StreamingContextType.ALBUM:
                    nextTrack = await GetNextAlbumTrackAsync(getNextTrackDto.CurrentTrackId, getNextTrackDto.ContextId.Value);
                    break;
                case StreamingContextType.PLAYLIST:
                    nextTrack = await GetNextPlaylistTrackAsync(getNextTrackDto.CurrentTrackId, getNextTrackDto.ContextId.Value);
                    break;
                case StreamingContextType.JAMENDO:
                    nextTrack = await GetNextTrackAsync(getNextTrackDto.CurrentTrackId, userId, getNextTrackDto.TrackHistoryIds);
                    break;
                case StreamingContextType.LIKED:
                    nextTrack = await GetNextLikedTrackAsync(getNextTrackDto.CurrentTrackId, userId, getNextTrackDto.TrackHistoryIds);
                    break;
                case StreamingContextType.ARTIST:
                    nextTrack = await GetNextArtistTrackAsync(getNextTrackDto.CurrentTrackId, getNextTrackDto.ContextId.Value);
                    break;
                default:
                    throw new ArgumentException("Invalid streaming context type");
            }

            if (nextTrack is null)
            {
                throw new Exception("Next track not found");
            }

            // Generate the signed URL for Musewave tracks
            if (nextTrack.JamendoId is null)
            {
                nextTrack.SignedUrl = GenerateSignedTrackUrl(nextTrack.FilePath, nextTrack.ArtistId.ToString());
            }
            // Check if the track is liked by the user
            if (getNextTrackDto.StreamingContextType == StreamingContextType.LIKED)
            {
                nextTrack.IsLiked = true;
            }
            else
            {
                nextTrack.IsLiked = await CheckIfTrackIsLikedByUser(nextTrack.Id, userId) != null;
            }
            return nextTrack;
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

        public async Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId)
        {
            return await _likeRepository.CheckIfTrackIsLikedByUser(trackId, userId);
        }

        public async Task<List<Track>> GetTracksByArtistId(int artistId)
        {
            return await _trackRepository.GetTracksByArtistId(artistId);
        }

        public async Task<List<Track>> GetTracksByUserId(string userId)
        {
            var artist = await _artistRepository.GetArtistByUserId(userId);
            if (artist is null)
            {
                return [];
            }
            return await _trackRepository.GetTracksByArtistId(artist.Id);
        }
        public async Task<Track> GetNextLikedTrackAsync(int currentTrackId, string userId, List<int> trackHistoryIds)
        {
            var currentTrack = await _trackRepository.GetById(currentTrackId);
            if (currentTrack is null)
            {
                throw new Exception("Current track not found");
            }

            Track nextTrack = null;
            IEnumerable<Track> likedTracks = await _trackRepository.GetLikedTracksAsync(userId);
            likedTracks = likedTracks.Where(x => !trackHistoryIds.Contains(x.Id))
                .Where(x => x.Id != currentTrackId);
            if (likedTracks.Count() > 0)
            {
                nextTrack = likedTracks.OrderBy(x => Guid.NewGuid()).FirstOrDefault(); // Random liked track
            }

            if (nextTrack is null)
            {
                // If there are no liked tracks, get a random track
                // If all tracks have been played, start over
                nextTrack = await _trackRepository.GetRandomTrack(excluding: trackHistoryIds) ?? await _trackRepository.GetRandomTrack(excluding: []);
            }
            return nextTrack;
        }

        public async Task<Track> GetNextArtistTrackAsync(int currentTrackId, int artistId)
        {
            var currentTrack = await _trackRepository.GetById(currentTrackId);
            if (currentTrack is null)
            {
                throw new Exception("Current track not found");
            }

            Track nextTrack = null;
            IEnumerable<Track> artistTracks = await _trackRepository.GetTracksByArtistId(currentTrack.ArtistId);
            artistTracks = artistTracks.Where(x => x.Id != currentTrackId);
            if (artistTracks.Count() > 0)
            {
                nextTrack = artistTracks.OrderBy(x => Guid.NewGuid()).FirstOrDefault(); // Random artist track
            }

            if (nextTrack is null)
            {
                // If there are no artist tracks, get a random track
                // If all tracks have been played, start over
                nextTrack = await _trackRepository.GetRandomTrack(excluding: []);
            }
            return nextTrack;
        }

        public async Task<IEnumerable<Track>> GetTracksAsync(TrackQuery query)
        {
            var results = new List<Track>();

            if (!string.IsNullOrEmpty(query.Name))
            {
                var tracksByName = await GetTracksByNameAsync(query.Name);
                results.AddRange(tracksByName);
            }

            if (query.ArtistId.HasValue)
            {
                var tracksByArtist = await GetTracksByArtistId(query.ArtistId.Value);
                results.AddRange(tracksByArtist);
            }

            // Remove duplicates if any
            return results.Distinct().ToList();
        }
    }
}
