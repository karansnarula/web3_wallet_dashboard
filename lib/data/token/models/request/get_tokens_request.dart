import 'package:json_annotation/json_annotation.dart';
import 'address_information.dart';

part 'get_tokens_request.g.dart';

@JsonSerializable()
class GetTokensRequest {
  final List<AddressInformation> addresses;

  GetTokensRequest({required this.addresses});

  factory GetTokensRequest.fromJson(Map<String, dynamic> json) =>
      _$GetTokensRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetTokensRequestToJson(this);
}
