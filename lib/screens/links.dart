import 'package:flutter/material.dart';
import 'package:slipmarks/screens/login.dart';
import 'package:slipmarks/services/auth_service.dart';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:http/http.dart' as http;

import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> _launchURL(String url) async {
  Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl)) {
    throw 'Could not launch $parsedUrl';
  }
}

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
  late Future<List<Bookmark>> _futureTemporaryBookmarks;

  @override
  void initState() {
    super.initState();

    _futureTemporaryBookmarks = fetchLinks();
  }

  Future<List<Bookmark>> fetchLinks() async {
    final url = Uri.parse("$SERVER_HOST/links");
    final accessToken = AuthService.instance.accessToken;
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      // (json.decode(response.body) as List) original, but didn't support äö characters.
      final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
          .map((bookmarkJson) => Bookmark.fromJson(bookmarkJson))
          .toList();

      return res;
    } else {
      // TODO: show an error in UI instead
      throw Exception('Failed to load temporary bookmarks');
    }
  }

  Future<void> _refreshLinks() async {
    setState(() {
      _futureTemporaryBookmarks = fetchLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _refreshLinks,
          child: FutureBuilder<List<Bookmark>>(
            future: _futureTemporaryBookmarks,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
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
                                link.iconUrl ??
                                    'assets/IL.png', // TODO: Add default bookmarkicon instead of IL.png
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
                                          color: Color(0xFF979797),
                                          fontSize: 12),
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
                                            color: Color(0xFFB1B1B1),
                                            fontSize: 12),
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
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
