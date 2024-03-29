using Microsoft.AspNetCore.Http;

namespace Models.DTOs
{
    public class TrackUploadDetailsDto : TrackUploadDto
    {
        public string trackName { get; set; }
        public int? albumId { get; set; }
        public string userId { get; set; }
    }
    public class TrackUploadDto
    {
        public IFormFile mediaFile { get; set; }
        public int? artistId { get; set; }
        public int trackId { get; set; }
        public string userId { get; set; }
    }

}
