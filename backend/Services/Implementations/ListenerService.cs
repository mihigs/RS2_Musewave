using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.SignalR;
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
        private readonly IHubContext<NotificationHub> _hubContext;

        public ListenerService(ITrackRepository trackRepository, IArtistRepository artistRepository, IConfiguration configuration, IHubContext<NotificationHub> hubContext)
        {
            _trackRepository = trackRepository ?? throw new ArgumentNullException(nameof(trackRepository));
            _artistRepository = artistRepository ?? throw new ArgumentNullException(nameof(artistRepository));
            _configuration = configuration;
            _hubContext = hubContext;
        }

        public async Task<BaseTrack> TrackUploadRequest(TrackUploadDetailsDto trackUploadDetailsDto)
        {
            // First create an entry in the database for the track
            var trackEntry = await CreateTrackDatabaseEntry(trackUploadDetailsDto);

            // Then send the track to the Listener for processing
            // The Listener only needs the artistId and the mediaFile
            var trackUploadDto = new TrackUploadDto
            {
                artistId = trackEntry.ArtistId,
                mediaFile = trackUploadDetailsDto.mediaFile,
                trackId = trackEntry.Id,
                userId = trackUploadDetailsDto.userId
            };
            await SendToListenerForProcessing(trackUploadDto);

            return trackEntry;
        }

        public async Task<BaseTrack> CreateTrackDatabaseEntry(TrackUploadDetailsDto trackDetails)
        {
            // Check if the user is an artist
            var artist = await _artistRepository.GetArtistByUserId(trackDetails.userId);
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
            var track = new BaseTrack
            {
                Title = trackDetails.trackName,
                ArtistId = artist.Id,
                Artist = artist
            };
            var result = await _trackRepository.Add(track);
            return result;
        }

        public async Task SendToListenerForProcessing(TrackUploadDto trackUploadDto)
        {
            try
            {
                using var client = new HttpClient();

                // Create a MultipartFormDataContent
                var content = new MultipartFormDataContent();

                // Convert the file into a ByteArrayContent
                byte[] fileBytes;
                using (var stream = trackUploadDto.mediaFile.OpenReadStream())
                {
                    using var ms = new MemoryStream();
                    await stream.CopyToAsync(ms);
                    fileBytes = ms.ToArray();
                }
                var fileContent = new ByteArrayContent(fileBytes);

                // Add the file content to the MultipartFormDataContent
                content.Add(fileContent, "mediaFile", trackUploadDto.mediaFile.FileName);

                // Add other properties to the MultipartFormDataContent
                content.Add(new StringContent(trackUploadDto.artistId.ToString()), "artistId");
                content.Add(new StringContent(trackUploadDto.trackId.ToString()), "trackId");
                content.Add(new StringContent(trackUploadDto.userId), "userId");

                // Send a POST request to the specified Uri
                var response = await client.PostAsync($"{_configuration["ListenerApiUrl"]}/Tracks/UploadTrack", content);

                // Ensure the request was successful
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("BaseTrack sent to Listener for processing.");
                }
                else
                {
                    Console.WriteLine("Failed to process track.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                await _hubContext.Clients.User(trackUploadDto.userId).SendAsync("UploadFailed", new { message = ex.Message });
            }
            return;
        }

    }
}
