namespace Listener.Models.DTOs
{
    public class TrackUploadDto
    {
        public IFormFile mediaFile { get; set; }
        public string artistId { get; set; }
        public string trackId { get; set; }
        public string userId { get; set; }
    }
}
