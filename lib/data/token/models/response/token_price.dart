import 'package:json_annotation/json_annotation.dart';

part 'token_price.g.dart';

@JsonSerializable()
class TokenPrice {
  final String currency;
  final String value;
  final String lastUpdatedAt;

  TokenPrice({
    required this.currency,
    required this.value,
    required this.lastUpdatedAt,
  });

  factory TokenPrice.fromJson(Map<String, dynamic> json) =>
      _$TokenPriceFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPriceToJson(this);
}
