using Models.Base;

namespace Models.Entities
{
    public class Like : BaseEntity
    {
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public int TrackId { get; set; }
        public virtual BaseTrack Track { get; set; }
    }
}
