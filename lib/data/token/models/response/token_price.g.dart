// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPrice _$TokenPriceFromJson(Map<String, dynamic> json) => TokenPrice(
  currency: json['currency'] as String,
  value: json['value'] as String,
  lastUpdatedAt: json['lastUpdatedAt'] as String,
);

Map<String, dynamic> _$TokenPriceToJson(TokenPrice instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'value': instance.value,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
