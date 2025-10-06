import 'package:json_annotation/json_annotation.dart';
import 'token_metadata.dart';
import 'token_price.dart';

part 'token_information.g.dart';

@JsonSerializable()
class TokenInformation {
  final String address;
  final String network;
  final String? tokenAddress;
  final String tokenBalance;
  final TokenMetadata? tokenMetadata;
  final List<TokenPrice>? tokenPrices;

  TokenInformation({
    required this.address,
    required this.network,
    this.tokenAddress,
    required this.tokenBalance,
    this.tokenMetadata,
    this.tokenPrices,
  });

  factory TokenInformation.fromJson(Map<String, dynamic> json) =>
      _$TokenInformationFromJson(json);

  Map<String, dynamic> toJson() => _$TokenInformationToJson(this);
}
