import 'package:flutter/material.dart';
import 'package:slipmarks/elements/add_bookmark_dialog.dart';
import 'package:slipmarks/models/collections.dart';
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

class Bookmarks extends ConsumerWidget {
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
                return GestureDetector(
                  onTap: () => closeCollection(collection.id),
                  child: SwipeableTile.card(
                    borderRadius: 10,
                    color: const Color(0xFF282828),
                    key: UniqueKey(),
                    swipeThreshold: 0.9,
                    direction: SwipeDirection.horizontal,
                    onSwiped: (direction) {
                      if (direction == SwipeDirection.startToEnd) {
                        // Handle right swipe
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Collection title
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  collection.name,
                                  // style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                              ),
                              // Collection URL
                              const Padding(
                                padding: EdgeInsets.only(right: 1),
                                child: Text(
                                  'collection.url',
                                  style: TextStyle(
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
}

Future<void> closeCollection(String collectionId) async {
  // Add the logic to close the collection based on the collectionId
  // For example, you can make an API call to update the collection status
  // to closed and then refresh the collectionsProvider to reflect the changes.
  // After that, you can update the UI or show a confirmation message to the user.
  try {
    // Example API call to close the collection
    // final response = await http.put(
    //   Uri.parse('$API_BASE_URL/collections/$collectionId/close'),
    //   headers: {'Authorization': 'Bearer $ACCESS_TOKEN'},
    // );
    // if (response.statusCode == 200) {
    //   // Collection closed successfully, refresh the collectionsProvider
    //   context.refresh(collectionsProvider);
    //   // Show a confirmation message to the user
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Collection closed successfully')),
    //   );
    // } else {
    //   // Failed to close the collection, show an error message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Failed to close the collection')),
    //   );
    // }
  } catch (e) {
    // Error handling for the API request
    // Show an error message to the user
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Error closing the collection: $e')),
    // );
  }
}
