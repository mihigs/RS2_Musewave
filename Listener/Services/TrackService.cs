using Listener.Models.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Listener.Services
{
    public class TrackService : ITrackService
    {
        private readonly string _storagePath;
        private readonly IRabbitMqService _rabbitMqService;

        public TrackService(IRabbitMqService rabbitMqService)
        {
            _storagePath = Path.Combine(Path.GetTempPath(), "musewave_tracks");
            _rabbitMqService = rabbitMqService;
        }

        public async Task ProcessTrack(TrackUploadDto model)
        {
            try 
            {
                // Ensure the storage directory exists
                var userDirectoryPath = Path.Combine(_storagePath, model.artistId);
                if (!Directory.Exists(userDirectoryPath))
                {
                    Directory.CreateDirectory(userDirectoryPath);
                }

                // Generate a unique file name with the current date appended
                var fileName = $"{Guid.NewGuid()}_{DateTime.Now.ToString("yyyyMMddHHmmss")}{Path.GetExtension(model.mediaFile.FileName)}";

                // Save the file to the user's directory
                var filePath = Path.Combine(userDirectoryPath, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await model.mediaFile.CopyToAsync(stream);
                }

                // Send the file name to the RabbitMQ service
                _rabbitMqService.SendMessage(new RabbitMqMessage
                {
                    Payload = fileName,
                    ArtistId = model.artistId,
                    TrackId = model.trackId
                });
            }
            catch (Exception ex) 
            {
                Console.WriteLine(ex.Message);
                throw new Exception("An error occurred while processing the track", ex);
            }
        }

        //public async Task<IActionResult> GetTrack(int artistId, string fileName)
        //{

        //}

    }
}
