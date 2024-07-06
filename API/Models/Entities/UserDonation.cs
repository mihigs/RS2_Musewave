using Models.Base;

namespace Models.Entities
{
    public class UserDonation : BaseEntity
    {
        public int Amount { get; set; }
        public string Currency { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
    }
}
