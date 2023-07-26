import 'package:json_annotation/json_annotation.dart';
part 'bookmark.g.dart';

@JsonSerializable()
class Bookmark {
  Bookmark({
    required this.id,
    required this.name,
    required this.url,
    required this.iconUrl,
    required this.createdAt,
  });
  final String id;
  final String name;
  final String url;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
