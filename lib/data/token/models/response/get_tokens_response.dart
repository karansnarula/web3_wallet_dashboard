import 'package:json_annotation/json_annotation.dart';
import 'token_data.dart';

part 'get_tokens_response.g.dart';

@JsonSerializable()
class GetTokensResponse {
  final TokenData data;

  GetTokensResponse({required this.data});

  factory GetTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$GetTokensResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetTokensResponseToJson(this);
}
