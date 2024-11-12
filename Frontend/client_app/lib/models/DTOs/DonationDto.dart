class DonationDto {
  final num amount;
  final String currency;
  final String paymentIntentId;
  final String paymentStatus;
  final String? paymentMethodId;

  DonationDto({
    required this.amount,
    required this.currency,
    required this.paymentIntentId,
    required this.paymentStatus,
    required this.paymentMethodId,
  });

  factory DonationDto.fromJson(Map<String, dynamic> json) {
    return DonationDto(
      amount: json['amount'],
      currency: json['currency'],
      paymentIntentId: json['paymentIntentId'],
      paymentStatus: json['paymentStatus'],
      paymentMethodId: json['paymentMethodId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus,
      'paymentMethodId': paymentMethodId,
    };
  }
}