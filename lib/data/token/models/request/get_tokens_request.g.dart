// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_tokens_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTokensRequest _$GetTokensRequestFromJson(Map<String, dynamic> json) =>
    GetTokensRequest(
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => AddressInformation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetTokensRequestToJson(GetTokensRequest instance) =>
    <String, dynamic>{'addresses': instance.addresses};
