import 'package:flutter/material.dart';
import 'package:slipmarks/elements/bookmarkEditSheet.dart';
import 'package:slipmarks/services/providers.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

Future<void> _launchURL(String url) async {
  Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl)) {
    throw 'Could not launch $parsedUrl';
  }
}

class Bookmarks extends ConsumerWidget {
  // Store the collection expansion state using a Set
  final Set<String> expandedCollections = {};

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
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsyncValue = ref.watch(collectionsProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: collectionsAsyncValue.when(
          data: (collections) {
            return ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                final isExpanded = expandedCollections.contains(collection.id);

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Toggle the collection expansion state
                        if (isExpanded) {
                          expandedCollections.remove(collection.id);
                        } else {
                          expandedCollections.add(collection.id);
                        }
                        // Refresh the UI after updating the expansion state
                        ref.refresh(collectionsProvider);
                      },
                      child: ListTile(
                        leading: const Icon(
                          Icons.folder_outlined,
                          color: Color(0xFFB1B1B1),
                        ),
                        title: Row(
                          children: [
                            Text(
                              collection.name,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_right,
                              color: const Color(0xFFB1B1B1),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.more_horiz,
                          color: Color(0xFFB1B1B1),
                        ),
                      ),
                    ),
                    // Show bookmarks when the collection is expanded
                    if (isExpanded) ..._buildBookmarksList(collection.id, ref),
                  ],
                );
              },
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
        ),
      ),
    );
  }

  List<Widget> _buildBookmarksList(String collectionId, WidgetRef ref) {
    final bookmarksAsyncValue =
        ref.watch(bookmarksByCollectionProvider(collectionId));
    return bookmarksAsyncValue.when(
      data: (bookmarks) {
        return [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return GestureDetector(
                onTap: () => _launchURL(bookmark.url),
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
                              bookmark: bookmark,
                              context: modalSheetContext,
                            ).editSheet(modalSheetContext),
                          ];
                        },
                      );
                    } else if (direction == SwipeDirection.endToStart) {
                      // Handle right to left swipe (Delete)
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 11),
                        child: FutureBuilder<Widget>(
                          future: _fetchFavicon(bookmark.iconUrl),
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
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bookmark title
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                bookmark.name,
                                // style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                            // Bookmark URL
                            Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: Text(
                                bookmark.url,
                                style: const TextStyle(
                                    color: Color(0xFF979797), fontSize: 12),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                            // Footer
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Triple dot
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: Color(0xFFB1B1B1),
                                    size: 18,
                                  ),
                                ),
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
        ];
      },
      error: (Object error, StackTrace stackTrace) {
        return [const Text('Error loading bookmarks')];
      },
      loading: () {
        return [const CircularProgressIndicator()];
      },
    );
  }
}
