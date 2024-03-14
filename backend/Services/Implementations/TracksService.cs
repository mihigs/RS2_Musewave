using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

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
    }
}
