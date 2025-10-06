// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenMetadata _$TokenMetadataFromJson(Map<String, dynamic> json) =>
    TokenMetadata(
      symbol: json['symbol'] as String?,
      decimals: (json['decimals'] as num?)?.toInt(),
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$TokenMetadataToJson(TokenMetadata instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'name': instance.name,
      'logo': instance.logo,
    };
