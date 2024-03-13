namespace Listener.Models.DTOs
{
    public class TrackUploadDto
    {
        public IFormFile mediaFile { get; set; }
        public string trackName { get; set; }
        public string userId { get; set; }
        public int? albumId { get; set; }
    }
}
