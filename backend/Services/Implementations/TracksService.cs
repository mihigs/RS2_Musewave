using DataContext.Repositories.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using System.Security.Claims;
using System.Text;

namespace Services.Implementations
{
    public class TracksService : ITracksService
    {
        private readonly ITrackRepository _trackRepository;

        public TracksService(ITrackRepository trackRespository)
        {
            _trackRepository = trackRespository ?? throw new ArgumentNullException(nameof(trackRespository));
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
        public async Task<Tuple<Track, string>> GetTrackByIdAsync(int id)
        {
            var trackResult = await _trackRepository.GetById(id);
            if (trackResult == null)
            {
                throw new Exception("Track not found");
            }

            var signedUrl = GenerateSignedTrackUrl(trackResult.FilePath, trackResult.ArtistId.ToString());
            return new Tuple<Track, string>(trackResult, signedUrl);
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
            var url = $"https://localhost:7151/api/Tracks/Stream/{listenerTrackId}?token={token}";
            return url;
        }
    }
}
