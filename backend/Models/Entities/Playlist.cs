using Models.Base;

namespace Models.Entities
{
    public class Playlist : BaseEntity
    {
        public string Name { get; set; }
        public string UserId { get; set; }
        public User User { get; set; }
        public List<Track> Tracks { get; set; }
        public bool IsPublic { get; set; }
        public Playlist()
        {
            Tracks = new List<Track>();
        }
    }

    public class PlaylistTrack
    {
        public int Id { get; set; }
        public int PlaylistId { get; set; }
        public Playlist Playlist { get; set; }
        public int TrackId { get; set; }
        public Track Track { get; set; }
    }
}
