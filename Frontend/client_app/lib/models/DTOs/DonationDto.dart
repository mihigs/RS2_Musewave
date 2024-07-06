class DonationDto {
  final num amount;
  final String currency;

  DonationDto({
    required this.amount,
    required this.currency,
  });

  factory DonationDto.fromJson(Map<String, dynamic> json) {
    return DonationDto(
      amount: json['amount'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}