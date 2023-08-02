import 'package:flutter/material.dart';
import 'package:slipmarks/elements/add_bookmark_popup.dart';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/services/providers.dart';

import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:slipmarks/bookmarkEditSheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

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
  Future<Widget> _fetchFavicon(String? iconUrl) async {
    try {
      if (iconUrl == null) {
        // Return the default website icon if iconUrl is null
        return const Icon(Icons.link);
      }

      final response = await http.get(Uri.parse(iconUrl));
      if (response.statusCode == 200) {
        // Return the fetched favicon as an Image widget
        return Image.memory(response.bodyBytes, width: 32, height: 32);
      } else {
        // Return the default website icon if fetching fails
        return const Icon(Icons.link);
      }
    } catch (e) {
      // Return the default website icon if an error occurs during fetching
      return const Icon(Icons.link);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer(builder: (context, ref, _) {
          final AsyncValue<List<Bookmark>> bookmarksAsyncValue =
              ref.watch(bookmarksProvider);
          return bookmarksAsyncValue.when(
            data: (bookmarks) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(bookmarksProvider);
                },
                child: ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final link = bookmarks[index];
                    return GestureDetector(
                      onTap: () => _launchURL(link.url),
                      child: SwipeableTile.card(
                        borderRadius: 10,
                        color: const Color(0xFF282828),
                        key: UniqueKey(),
                        swipeThreshold: 0.9,
                        direction: SwipeDirection.horizontal,
                        onSwiped: (direction) {
                          if (direction == SwipeDirection.startToEnd) {
                            // Handle right swipe
                            WoltModalSheet.show<void>(
                              context: context,
                              pageListBuilder: (modalSheetContext) {
                                return [
                                  BookmarkEditSheet(
                                    bookmark: link,
                                    context: modalSheetContext,
                                  ).editSheet(modalSheetContext),
                                ];
                              },
                            );
                          } else if (direction == SwipeDirection.endToStart) {
                            // Handle right to left swipe
                          }
                        },
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
                            FutureBuilder<Widget>(
                              future: _fetchFavicon(link.iconUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Return a loading indicator while fetching the favicon
                                  return const CircularProgressIndicator();
                                } else {
                                  // Return the fetched favicon or default website icon
                                  return snapshot.data!;
                                }
                              },
                            ),
                            // child: Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       vertical: 9, horizontal: 11),
                            //   child: Image.asset(
                            //     link.iconUrl ??
                            //         'assets/IL.png', // TODO: Add default bookmarkicon instead of IL.png
                            //     width: 32,
                            //     height: 32,
                            //   ),
                            // ),
                            // ),
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
                ),
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return const Center(
                child: Text('Error loading data'),
              );
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show the bottom sheet for adding a new bookmark
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return AddBookmarkBottomSheet();
              },
            );
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
