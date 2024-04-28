using Models.Base;

namespace Models.Entities
{
    public class LoginActivity : BaseEntity
    {
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public bool IsSuccessful { get; set; }
    }
}
