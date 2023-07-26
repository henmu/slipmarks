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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<BookmarkInfo>>(
        future: _linksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          } else {
            final links = snapshot.data ?? [];
            return ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return GestureDetector(
                  onTap: () => _launchURL(link.url),
                  child: SwipeableTile.card(
                    borderRadius: 10,
                    color: const Color(0xFF282828),
                    // color: Colors.white,
                    key: UniqueKey(),
                    swipeThreshold: 0.9,
                    direction: SwipeDirection.horizontal,
                    onSwiped: (_) {},
                    backgroundBuilder: (context, direction, progress) {
                      if (direction == SwipeDirection.endToStart) {
                        return Container(
                          color: Colors.red,
                        );
                      } else if (direction == SwipeDirection.startToEnd) {
                        return Container(
                          color: Colors.green,
                        );
                      }
                      return Container();
                    },
                    horizontalPadding: 16,
                    verticalPadding: 8,
                    shadow: BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 11),
                          child: Image.asset(
                            link.iconUrl, // Assuming the icon images are inside the assets folder
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Links title
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  link.name,
                                  // style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                              ),
                              //Links URL
                              Padding(
                                padding: const EdgeInsets.only(right: 1),
                                child: Text(
                                  link.url,
                                  style: const TextStyle(
                                      color: Color(0xFF979797), fontSize: 12),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                              ),
                              //Footer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //Timestamp
                                  Text(
                                    link.createdAt,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Color(0xFFB1B1B1), fontSize: 12),
                                  ),
                                  //Triple dot
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFFB1B1B1),
                                      size: 18,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
