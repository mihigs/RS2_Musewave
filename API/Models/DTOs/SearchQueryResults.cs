using Models.Entities;

namespace Models.DTOs
{
    public class SearchQueryResults
    {
        public List<Track> Tracks { get; set; } = new List<Track>();
        public List<Album> Albums { get; set;} = new List<Album>();
        public List<Artist> Artists { get; set; } = new List<Artist>();
        public List<Track> JamendoTracks { get; set; } = new List<Track>();
        public List<Playlist> Playlists { get; set; } = new List<Playlist>();
    }

}
