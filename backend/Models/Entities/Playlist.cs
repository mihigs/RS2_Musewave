using Models.Base;

namespace Models.Entities
{
    public class Playlist : BaseEntity
    {
        public string Name { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public virtual List<PlaylistTrack> Tracks { get; set; } = new List<PlaylistTrack>();
        public bool IsPublic { get; set; }
        public bool IsExploreWeekly { get; set; }
    }

    public class PlaylistTrack
    {
        public int PlaylistId { get; set; }
        public virtual Playlist Playlist { get; set; }
        public int TrackId { get; set; }
        public virtual Track Track { get; set; }
    }
}
