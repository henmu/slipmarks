import 'package:flutter/material.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class BookmarkInfo {
  final String name;
  final String url;
  final String iconUrl;
  final String createdAt;

  BookmarkInfo({
    required this.name,
    required this.url,
    required this.iconUrl,
    required this.createdAt,
  });

  factory BookmarkInfo.fromJson(Map<String, dynamic> json) {
    return BookmarkInfo(
      name: json['name'],
      url: json['url'],
      iconUrl: json['iconUrl'],
      createdAt: json['createdAt'],
    );
  }
}

Future<List<BookmarkInfo>> _loadLinkData() async {
  final String data = await rootBundle.loadString('links_data.json');
  final List<dynamic> jsonList = json.decode(data);
  return jsonList.map((json) => BookmarkInfo.fromJson(json)).toList();
}

Future<void> _launchURL(String url) async {
  Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl)) {
    throw 'Could not launch $parsedUrl';
  }
}

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late Future<List<BookmarkInfo>> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = _loadLinkData();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'This is the Search page',
          style: TextStyle(
            fontFamily: 'Inter',
            // color: Colors.white,
          ),
        ),
      ),
    );
  }
}
