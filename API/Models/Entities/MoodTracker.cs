using Models.Base;
using Models.Enums;

namespace Models.Entities
{
    public class MoodTracker : BaseEntity
    {
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public MoodType MoodType { get; set; }
        public string? Description { get; set; }
        public DateTime RecordDate { get; set; }
    }
}
