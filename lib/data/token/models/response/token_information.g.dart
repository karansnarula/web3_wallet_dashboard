// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenInformation _$TokenInformationFromJson(Map<String, dynamic> json) =>
    TokenInformation(
      address: json['address'] as String,
      network: json['network'] as String,
      tokenAddress: json['tokenAddress'] as String?,
      tokenBalance: json['tokenBalance'] as String,
      tokenMetadata: json['tokenMetadata'] == null
          ? null
          : TokenMetadata.fromJson(
              json['tokenMetadata'] as Map<String, dynamic>,
            ),
      tokenPrices: (json['tokenPrices'] as List<dynamic>?)
          ?.map((e) => TokenPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenInformationToJson(TokenInformation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'network': instance.network,
      'tokenAddress': instance.tokenAddress,
      'tokenBalance': instance.tokenBalance,
      'tokenMetadata': instance.tokenMetadata,
      'tokenPrices': instance.tokenPrices,
    };
