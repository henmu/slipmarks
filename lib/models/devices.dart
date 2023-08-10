import 'package:json_annotation/json_annotation.dart';
part 'devices.g.dart';

@JsonSerializable()
class Devices {
  Devices({
    required this.id,
    required this.device_name,
    required this.platform,
  });
  final String id;
  final String? device_name;
  final String platform;

  factory Devices.fromJson(Map<String, dynamic> json) =>
      _$DevicesFromJson(json);

  Map<String, dynamic> toJson() => _$DevicesToJson(this);
}
