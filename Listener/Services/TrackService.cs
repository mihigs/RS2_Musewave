using Listener.Models.DTOs;

namespace Listener.Services
{
    public class TrackService : ITrackService
    {
        private readonly string _storagePath;

        public TrackService()
        {
            _storagePath = Path.Combine(Path.GetTempPath(), "musewave_tracks");
        }

        public async Task ProcessTrack(TrackUploadDto model)
        {
            try 
            {
                // Ensure the storage directory exists
                var userDirectoryPath = Path.Combine(_storagePath, model.userId);
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
                //// Ensure the storage directory exists
                //if (!Directory.Exists(_storagePath))
                //{
                //    Directory.CreateDirectory(_storagePath);
                //}

                //// Save the file to the storage directory
                //var filePath = Path.Combine(_storagePath, model.mediaFile.FileName);
                //using (var stream = new FileStream(filePath, FileMode.Create))
                //{
                //    await model.mediaFile.CopyToAsync(stream);
                //}
            } 
            catch (Exception ex) 
            {
                Console.WriteLine(ex.Message);
                throw new Exception("An error occurred while processing the track", ex);
            }

            // Send message to RabbitMQ here
            //NotifyTrackUploaded(filePath);
        }
    }
}
