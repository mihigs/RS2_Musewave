namespace Models.DTOs
{
    public class TrackUpdateDto
    {
        public int trackId { get; set; }
        public string trackName { get; set; }
        public int? albumId { get; set; }
    }
}
