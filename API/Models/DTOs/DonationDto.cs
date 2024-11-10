
namespace Models.DTOs
{
    public class DonationDto
    {
        public int Amount { get; set; }
        public string Currency { get; set; }
        public string PaymentIntentId { get; set; }
        public string PaymentStatus { get; set; }
        public string PaymentMethodId { get; set; }
    }
}
