import 'package:json_annotation/json_annotation.dart';
import 'token_information.dart';

part 'token_data.g.dart';

@JsonSerializable()
class TokenData {
  final List<TokenInformation> tokens;
  final String? pageKey;

  TokenData({
    required this.tokens,
    this.pageKey,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) =>
      _$TokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenDataToJson(this);
}
