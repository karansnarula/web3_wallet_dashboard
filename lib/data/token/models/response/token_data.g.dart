// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenData _$TokenDataFromJson(Map<String, dynamic> json) => TokenData(
  tokens: (json['tokens'] as List<dynamic>)
      .map((e) => TokenInformation.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageKey: json['pageKey'] as String?,
);

Map<String, dynamic> _$TokenDataToJson(TokenData instance) => <String, dynamic>{
  'tokens': instance.tokens,
  'pageKey': instance.pageKey,
};
