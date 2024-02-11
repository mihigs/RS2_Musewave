using Models.Base;

namespace Models
{
    public class Playlist : BaseEntity
    {
        public string Name { get; set; }
        public string UserId { get; set; }
        public User User { get; set; }
        public List<PlaylistTrack> PlaylistTracks { get; set; }
    }

    public class PlaylistTrack
    {
        public int PlaylistId { get; set; }
        public Playlist Playlist { get; set; }
        public int TrackId { get; set; }
        public Track Track { get; set; }
    }
}
