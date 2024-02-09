namespace Models
{
    public class Track
    {
        public int TrackId { get; set; }
        public string Title { get; set; }
        public int Duration { get; set; }
        public int AlbumId { get; set; }
        public Album Album { get; set; }
    }
}
