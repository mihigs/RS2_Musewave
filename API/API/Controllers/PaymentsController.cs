using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Services.Interfaces;
using Stripe;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentsService _paymentsService;

        public PaymentsController(IPaymentsService paymentsService)
        {
            _paymentsService = paymentsService ?? throw new ArgumentNullException(nameof(paymentsService));
        }

        [HttpGet("GetPaymentDetails")]
        public async Task<ApiResponse> GetPaymentDetails(string paymentIntentId)
        {
            ApiResponse apiResponse = new ApiResponse();

            try
            {
                var paymentIntent = await _paymentsService.GetPaymentIntentAsync(paymentIntentId);

                apiResponse.Data = paymentIntent;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (StripeException ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
            }

            return apiResponse;
        }

        [HttpPost("CreatePaymentIntent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentIntentCreateRequest request)
        {
            ApiResponse apiResponse = new ApiResponse();

            try
            {
                var paymentIntent = await _paymentsService.CreatePaymentIntentAsync(request.Amount);

                apiResponse.Data = new { clientSecret = paymentIntent.ClientSecret };
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;

                return Ok(apiResponse);
            }
            catch (StripeException ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                return StatusCode((int)System.Net.HttpStatusCode.InternalServerError, apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                return StatusCode((int)System.Net.HttpStatusCode.InternalServerError, apiResponse);
            }
        }

        [HttpPost("LogDonationAsync")]
        public async Task<ApiResponse> LogDonationAsync(DonationDto donation)
        {
            ApiResponse apiResponse = new ApiResponse();

            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                var userId = userIdClaim.Value;

                await _paymentsService.LogDonationAsync(donation, userId);

                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
            }

            return apiResponse;
        }
    }
}
