import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slipmarks/elements/bookmark_addition_sheet.dart';
import 'package:slipmarks/elements/bookmark_popup_menu.dart';
import 'package:slipmarks/elements/open_send_dialog.dart';
import 'package:slipmarks/helpers/datetime_helper.dart';
import 'package:slipmarks/services/providers.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

//TODO: Refresh collectionsBookmarks somehow
//TODO: Add collection edit/remove
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
            //Sort collections alphabetically
            collections.sort(
              (a, b) => a.name.compareTo(b.name),
            );
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
                          ref.refresh(
                              bookmarksByCollectionProvider(collection.id));
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
                        trailing: BookmarkPopupMenu(
                          icon: Icons.more_vert,
                          iconColor: const Color(0xFFB1B1B1),
                          iconSize: 24,
                          menuItems: [
                            // PopupMenuItemInfo(
                            //     label: 'Details', value: 'details'),
                            PopupMenuItemInfo(label: 'Edit', value: 'edit'),
                            PopupMenuItemInfo(label: 'Delete', value: 'delete'),
                          ],
                          onItemSelected: (String choice) {
                            if (choice == 'edit') {
                              // Handle "Edit" action
                            } else if (choice == 'delete') {
                              // Handle "Remove" action
                            }
                          },
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
        //Sort Bookmarks from newest to oldest
        bookmarks.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        return [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final link = bookmarks[index];
              return GestureDetector(
                onTap: () {
                  final openAndSendDialog =
                      OpenAndSendDialog(bookmark: link, context: context);
                  openAndSendDialog.openAndSendDialog();
                },
                child: SwipeableTile.card(
                  borderRadius: 10,
                  color: const Color(0xFF282828),
                  key: UniqueKey(),
                  swipeThreshold: 0.7,
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
                      // Handle right to left swipe (Delete)
                      try {
                        ref.read(bookmarkDeletionProvider(link.id!));
                      } catch (e) {
                        print('Error deleting bookmark: $e');
                        // Show an error message to the user
                      }
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
                                  DateTimeHelper.formatDateTime(link.createdAt),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      color: Color(0xFFB1B1B1), fontSize: 12),
                                ),
                                // Triple dot menu
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: BookmarkPopupMenu(
                                    icon: Icons.more_horiz,
                                    iconColor: const Color(0xFFB1B1B1),
                                    iconSize: 20,
                                    menuItems: [
                                      PopupMenuItemInfo(
                                          label: 'Details', value: 'details'),
                                      PopupMenuItemInfo(
                                          label: 'Add', value: 'add'),
                                      PopupMenuItemInfo(
                                          label: 'Edit', value: 'edit'),
                                      PopupMenuItemInfo(
                                          label: 'Delete', value: 'delete'),
                                    ],
                                    onItemSelected: (String choice) {
                                      if (choice == 'details') {
                                        // Handle "Details" action
                                      } else if (choice == 'add') {
                                        // Handle "Add" action
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
                                      } else if (choice == 'edit') {
                                        // Show a dialog with a text field for the new bookmark name
                                        //TODO: Refresh when success response from server
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            TextEditingController
                                                newNameController =
                                                TextEditingController();
                                            return AlertDialog(
                                              title: const Text(
                                                  'Edit Bookmark Name'),
                                              content: TextField(
                                                controller: newNameController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'New Bookmark Name'),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  child: const Text('Save'),
                                                  onPressed: () async {
                                                    String newBookmarkName =
                                                        newNameController.text;
                                                    if (newBookmarkName
                                                        .isNotEmpty) {
                                                      try {
                                                        // Call the provider to update the bookmark name
                                                        final bookmarkUpdateParams =
                                                            BookmarkUpdateParameters(
                                                                link.id,
                                                                newBookmarkName);
                                                        await ref.read(
                                                            bookmarkNameUpdateProvider(
                                                                    bookmarkUpdateParams)
                                                                .future);
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop(); // Close the dialog
                                                      } catch (error) {
                                                        print(
                                                            'Failed to update bookmark name: $error');
                                                        // Handle the error, e.g., show an error message to the user
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (choice == 'delete') {
                                        // Handle "Remove" action
                                        //TODO: Hide the SwipeableTile.card when remove is pressed
                                        try {
                                          ref.read(bookmarkDeletionProvider(
                                              link.id!));
                                        } catch (e) {
                                          print('Error deleting bookmark: $e');
                                          // Show an error message to the user
                                        }
                                      }
                                    },
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
