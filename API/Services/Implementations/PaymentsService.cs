using DataContext.Repositories;
using Microsoft.Extensions.Options;
using Models.Base;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using Stripe;

namespace Services.Implementations
{
    public class PaymentsService : IPaymentsService
    {
        private readonly StripeSettings _stripeSettings;
        private readonly IUserDonationRepository _userDonationRepository;

        public PaymentsService(IOptions<StripeSettings> stripeSettings, IUserDonationRepository userDonationRepository)
        {
            _stripeSettings = stripeSettings.Value ?? throw new ArgumentNullException(nameof(stripeSettings));
            _userDonationRepository = userDonationRepository;
        }

        public async Task<PaymentIntent> CreatePaymentIntentAsync(long amount)
        {
            StripeConfiguration.ApiKey = _stripeSettings.SecretKey;

            var options = new PaymentIntentCreateOptions
            {
                Amount = amount,
                Currency = "usd",
                PaymentMethodTypes = new List<string> { "card" },
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            return paymentIntent;
        }

        public async Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId)
        {
            StripeConfiguration.ApiKey = _stripeSettings.SecretKey;
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(paymentIntentId);

            return paymentIntent;
        }

        public async Task LogDonationAsync(DonationDto donation, string userId)
        {
            await _userDonationRepository.Add(new UserDonation
            {
                Amount = donation.Amount,
                Currency = donation.Currency,
                UserId = userId,
                PaymentIntentId = donation.PaymentIntentId,
                PaymentStatus = donation.PaymentStatus,
                PaymentMethodId = donation.PaymentMethodId
            });
        }
    }
}
