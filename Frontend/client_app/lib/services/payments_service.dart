import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/models/DTOs/DonationDto.dart';
import 'package:frontend/models/payment_intent.dart' as CustomPaymentIntent;
import 'package:frontend/services/base/api_service.dart';

class PaymentsService extends ApiService {

  PaymentsService(FlutterSecureStorage secureStorage)
      : super(secureStorage: secureStorage);

  Future<void> initialize(stripePublishableKey) async {
    Stripe.publishableKey = stripePublishableKey;
  }

  Future<CustomPaymentIntent.PaymentIntent> createPaymentIntent(int amount) async {
    try {
      final response = await httpPost('Payments/CreatePaymentIntent', {'amount': amount});
      return CustomPaymentIntent.PaymentIntent.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<CustomPaymentIntent.PaymentIntent> getPaymentDetails(String paymentIntentId) async {
    try {
      final response = await httpGet('Payments/GetPaymentDetails/$paymentIntentId');
      return CustomPaymentIntent.PaymentIntent.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
  }

  Future<void> logDonation(DonationDto paymentIntent) async {
    try {
      await httpPost('Payments/LogDonationAsync', paymentIntent.toJson());
    } on Exception {
      rethrow;
    }
  }
}
