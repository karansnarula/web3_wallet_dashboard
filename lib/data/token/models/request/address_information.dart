import 'package:json_annotation/json_annotation.dart';

part 'address_information.g.dart';

@JsonSerializable()
class AddressInformation {
  final String address;
  final List<String> networks;

  AddressInformation({
    required this.address,
    required this.networks,
  });

  factory AddressInformation.fromJson(Map<String, dynamic> json) =>
      _$AddressInformationFromJson(json);

  Map<String, dynamic> toJson() => _$AddressInformationToJson(this);
}
