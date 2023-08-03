import 'package:json_annotation/json_annotation.dart';
part 'bookmark.g.dart';

@JsonSerializable()
class Bookmark {
  Bookmark({
    this.id,
    required this.name,
    required this.url,
    this.iconUrl,
    this.createdAt,
  });

  String? id;
  final String name;
  final String url;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'icon_url': iconUrl,
    };
  }
}
