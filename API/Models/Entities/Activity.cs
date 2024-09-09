using Models.Base;
using Models.Enums;

namespace Models.Entities
{
    public class Activity : BaseEntity
    {
        public string? UserId { get; set; }
        public virtual User? User { get; set; }
        public bool? IsSuccessful { get; set; }
        public ActivityType ActivityType { get; set; }
        public bool IsJamendoApiRequest { get; set; }
    }
}
