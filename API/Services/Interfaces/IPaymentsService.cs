using Models.DTOs;
using Stripe;

namespace Services.Interfaces
{
    public interface IPaymentsService
    {
        Task<PaymentIntent> CreatePaymentIntentAsync(long amount);
        Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId);
        Task LogDonationAsync(DonationDto donation, string userId);
    }
}
