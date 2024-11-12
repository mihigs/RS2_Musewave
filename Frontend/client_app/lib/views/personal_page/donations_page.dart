import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/DonationDto.dart';
import 'package:frontend/services/payments_service.dart';
import 'package:frontend/widgets/cards/donations_card.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DonationsPage extends StatelessWidget {
  final PaymentsService paymentsService = GetIt.I<PaymentsService>(); // Get PaymentsService instance

  DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.donations),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.donations_message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DonationCard(
              label: '1 USD',
              onDonate: () => _donate(context, 100),
            ),
            DonationCard(
              label: '10 USD',
              onDonate: () => _donate(context, 1000),
            ),
            DonationCard(
              label: '100 USD',
              onDonate: () => _donate(context, 10000),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _donate(BuildContext context, int amount) async {
    try {
      // Create a payment intent
      final paymentIntent = await paymentsService.createPaymentIntent(amount);

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Musewave',
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Fetch the payment intent to get the details of the payment
      final paymentIntentResult = await Stripe.instance.retrievePaymentIntent(paymentIntent.clientSecret);

      // Handle successful payment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.donation_success)),
      );

      // Log donation
      DonationDto donation = DonationDto(
        amount: paymentIntentResult.amount,
        currency: paymentIntentResult.currency,
        paymentIntentId: paymentIntentResult.id,
        paymentStatus: paymentIntentResult.status.name,
        paymentMethodId: paymentIntentResult.paymentMethodId,
      );
      await paymentsService.logDonation(donation);

    } on StripeException catch (e) {
      // Handle Stripe-specific exceptions
      if (e.error.code == FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.payment_canceled)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.payment_failed}: ${e.error.message}')),
        );
      }
    } catch (e) {
      // Handle other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.payment_failed}: $e')),
      );
    }
  }
}