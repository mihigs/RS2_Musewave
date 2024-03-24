using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.Configuration;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class ListenerService : IListenerService
    {
        private readonly ITrackRepository _trackRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IConfiguration _configuration;

        public ListenerService(ITrackRepository trackRepository, IArtistRepository artistRepository, IConfiguration configuration)
        {
            _trackRepository = trackRepository ?? throw new ArgumentNullException(nameof(trackRepository));
            _artistRepository = artistRepository ?? throw new ArgumentNullException(nameof(artistRepository));
            _configuration = configuration;
        }

        public async Task<Track> TrackUploadRequest(TrackUploadDetailsDto trackUploadDetailsDto)
        {
            // First create an entry in the database for the track
            var trackEntry = await CreateTrackDatabaseEntry(trackUploadDetailsDto);

            // Then send the track to the Listener for processing
            // The Listener only needs the artistId and the mediaFile
            var trackUploadDto = new TrackUploadDto
            {
                artistId = trackEntry.ArtistId,
                mediaFile = trackUploadDetailsDto.mediaFile,
                trackId = trackEntry.Id
            };
            SendToListenerForProcessing(trackUploadDto);

            return trackEntry;
        }

        public async Task<Track> CreateTrackDatabaseEntry(TrackUploadDetailsDto trackDetails)
        {
            // Check if the user is an artist
            var artist = await _artistRepository.GetArtistByUserIdAsync(trackDetails.userId);
            if (artist == null)
            {
                // create an artist entry in the database
                artist = new Artist
                {
                    UserId = trackDetails.userId
                };
                await _artistRepository.Add(artist);
            }

            // create a track entry in the database
            var track = new Track
            {
                Title = trackDetails.trackName,
                ArtistId = artist.Id
            };
            var result = await _trackRepository.Add(track);
            return result;
        }
        public async Task SendToListenerForProcessing(TrackUploadDto trackUploadDto)
        {
            var client = new HttpClient();

            // Create a MultipartFormDataContent
            var content = new MultipartFormDataContent();

            // Convert the file into a ByteArrayContent
            using var ms = new MemoryStream();
            await trackUploadDto.mediaFile.CopyToAsync(ms);
            var fileBytes = ms.ToArray();
            var fileContent = new ByteArrayContent(fileBytes);

            // Add the file content to the MultipartFormDataContent
            content.Add(fileContent, "mediaFile", trackUploadDto.mediaFile.FileName);

            // Add other properties to the MultipartFormDataContent
            content.Add(new StringContent(trackUploadDto.artistId.ToString()), "artistId");
            content.Add(new StringContent(trackUploadDto.trackId.ToString()), "trackId");

            // Send a POST request to the specified Uri
            var response = await client.PostAsync($"{_configuration["ListenerApiUrl"]}/Tracks/UploadTrack", content);

            // Ensure the request was successful
            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine("Track sent to Listener for processing.");
            }
            else
            {
                Console.WriteLine("Failed to process track.");
            }
        }

    }
}
