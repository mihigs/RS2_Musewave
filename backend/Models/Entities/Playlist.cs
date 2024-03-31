using Models.Base;

namespace Models.Entities
{
    public class Playlist : BaseEntity
    {
        public string Name { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public virtual List<BaseTrack> Tracks { get; set; }
        public bool IsPublic { get; set; }
        public Playlist()
        {
            Tracks = new List<BaseTrack>();
        }
    }

    public class PlaylistTrack
    {
        public int Id { get; set; }
        public int PlaylistId { get; set; }
        public virtual Playlist Playlist { get; set; }
        public int TrackId { get; set; }
        public virtual BaseTrack Track { get; set; }
    }
}
