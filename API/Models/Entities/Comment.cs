using Models.Base;

namespace Models.Entities
{
    public class Comment : BaseEntity
    {
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public int TrackId { get; set; }
        public virtual Track Track { get; set; }
        public string Text { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}
