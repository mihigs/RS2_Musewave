namespace Models
{
    public class Album
    {
        public int AlbumId { get; set; }
        public string Title { get; set; }
        public string Genre { get; set; }
        public string ArtistId { get; set; }
        public Artist Artist { get; set; }
        public List<Track> Tracks { get; set; }
    }
}
