import 'package:json_annotation/json_annotation.dart';

part 'token_metadata.g.dart';

@JsonSerializable()
class TokenMetadata {
  final String? symbol;
  final int? decimals;
  final String? name;
  final String? logo;

  TokenMetadata({
    this.symbol,
    this.decimals,
    this.name,
    this.logo,
  });

  factory TokenMetadata.fromJson(Map<String, dynamic> json) =>
      _$TokenMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenMetadataToJson(this);
}
