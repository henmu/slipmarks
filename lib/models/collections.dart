import 'package:json_annotation/json_annotation.dart';
part 'collections.g.dart';

@JsonSerializable()
class Collections {
  Collections({
    required this.id,
    required this.name,
    required this.type,
  });
  final String id;
  final String name;
  final String? type;

  factory Collections.fromJson(Map<String, dynamic> json) =>
      _$CollectionsFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionsToJson(this);
}
