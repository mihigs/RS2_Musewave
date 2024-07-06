import 'package:json_annotation/json_annotation.dart';

part 'payment_intent.g.dart';

@JsonSerializable()
class PaymentIntent {
  String clientSecret;

  PaymentIntent({required this.clientSecret});

  factory PaymentIntent.fromJson(Map<String, dynamic> json) => _$PaymentIntentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentIntentToJson(this);
}
