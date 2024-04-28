using Models.Base;
using Models.Enums;

namespace Models.Entities
{
    public class JamendoAPIActivity : BaseEntity
    {
        public string? UserId { get; set; }
        public virtual User? User { get; set; }
        public JamendoAPIActivityType ActivityType { get; set; }
    }

}
