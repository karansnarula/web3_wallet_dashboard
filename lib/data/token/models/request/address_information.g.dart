// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressInformation _$AddressInformationFromJson(Map<String, dynamic> json) =>
    AddressInformation(
      address: json['address'] as String,
      networks: (json['networks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AddressInformationToJson(AddressInformation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'networks': instance.networks,
    };
