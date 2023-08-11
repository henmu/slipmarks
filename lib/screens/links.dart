import 'package:flutter/material.dart';
import 'package:slipmarks/elements/filter_dropdown_button.dart';
import 'package:slipmarks/elements/new_bookmark_dialog.dart';
import 'package:slipmarks/elements/bookmark_popup_menu.dart';
import 'package:slipmarks/elements/open_send_dialog.dart';
import 'package:slipmarks/helpers/datetime_helper.dart';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/services/providers.dart';

import 'package:swipeable_tile/swipeable_tile.dart';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:slipmarks/elements/bookmark_addition_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Links extends ConsumerStatefulWidget {
  const Links({super.key});

  @override
  _LinksStateState createState() => _LinksStateState();
}

class _LinksStateState extends ConsumerState<Links> {
  String selectedFilter = '7d'; // Default filter
  bool sortByNewest = false; // Default sorting order
  IconData sortIcon = Icons.sort;
  List<Bookmark> bookmarks = [];

  // Options for filter
  List<Bookmark> filteredBookmarks = [];
  List<int> filterDurations = [1, 3, 7, 14];
  List<String> filterOptions = ['1d', '3d', '7d', '14d'];

  DateTime parseCreatedAt(String createdAt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(createdAt, true);
  }

  List<Bookmark> filterBookmarks(List<Bookmark> bookmarks, int days) {
    final DateTime currentDate = DateTime.now();
    final DateTime filterDate = currentDate.subtract(Duration(days: days));

    return bookmarks.where((bookmark) {
      final createdAt = parseCreatedAt(bookmark.createdAt!);
      return createdAt.isAfter(filterDate);
    }).toList();
  }

  // Function to update the selected filter
  void updateFilter(String filter) {
    int days = filterDurations[filterOptions.indexOf(filter)];
    List<Bookmark> filteredBookmarks = filterBookmarks(bookmarks, days);

    setState(() {
      selectedFilter = filter;
      this.filteredBookmarks = filteredBookmarks;
    });
  }

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _deleteBookmark(String bookmarkId) async {
    try {
      ref.read(bookmarkDeletionProvider(bookmarkId));
    } catch (e) {
      print('Error deleting bookmark: $e');
      // Show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            //Header with filter and sort options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //TODO: Add functionality to choose between All and Day filter
                  Row(
                    children: [
                      //Filter Text
                      const Text('All', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      FilterDropDown(
                        options: filterOptions,
                        selectedOption: selectedFilter,
                        onOptionSelected: (newValue) {
                          updateFilter(newValue);
                        },
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        sortByNewest = !sortByNewest;
                        sortIcon = sortByNewest
                            ? Icons.arrow_downward
                            : Icons.arrow_upward;
                        if (sortByNewest) {
                          bookmarks.sort(
                              (a, b) => b.createdAt!.compareTo(a.createdAt!));
                        } else {
                          bookmarks.sort(
                              (a, b) => a.createdAt!.compareTo(b.createdAt!));
                        }
                      });
                    },
                    child: Row(
                      children: [
                        const Text('Sort'),
                        const SizedBox(width: 4),
                        Icon(
                          sortIcon,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final AsyncValue<List<Bookmark>> bookmarksAsyncValue =
                    ref.watch(bookmarksFutureProvider);
                return bookmarksAsyncValue.when(
                  data: (bookmarksData) {
                    //Sort Bookmarks from newest to oldest
                    bookmarks = bookmarksData;
                    if (!sortByNewest) {
                      // If sorting order is oldest to newest, reverse the list
                      bookmarks = bookmarks.reversed.toList();
                    }
                    // Filter bookmarks based on the selected filter
                    int days =
                        filterDurations[filterOptions.indexOf(selectedFilter)];
                    filteredBookmarks = filterBookmarks(bookmarks, days);

                    // Print all items in filteredBookmarks for debugging
                    print('Filtered Bookmarks:');
                    for (var bookmark in filteredBookmarks) {
                      print(bookmark.name);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(bookmarksFutureProvider);
                      },
                      child: ListView.builder(
                        itemCount: filteredBookmarks.length,
                        itemBuilder: (context, index) {
                          final link = filteredBookmarks[index];
                          return GestureDetector(
                            onTap: () {
                              final openAndSendDialog = OpenAndSendDialog(
                                  bookmark: link, context: context);
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
                                } else if (direction ==
                                    SwipeDirection.endToStart) {
                                  // Handle right to left swipe (Delete)
                                  _deleteBookmark(link.id!);
                                }
                              },
                              backgroundBuilder:
                                  (context, direction, progress) {
                                if (direction == SwipeDirection.endToStart) {
                                  return Container(
                                    color: Colors.red,
                                  );
                                } else if (direction ==
                                    SwipeDirection.startToEnd) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Links title
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            link.name,
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                          ),
                                        ),
                                        //Links URL
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 1),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            //Timestamp
                                            Text(
                                              DateTimeHelper.formatDateTime(
                                                  link.createdAt),
                                              // _formatDateTime(link.createdAt),
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: Color(0xFFB1B1B1),
                                                  fontSize: 12),
                                            ),
                                            // Triple dot menu
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: BookmarkPopupMenu(
                                                icon: Icons.more_horiz,
                                                iconColor:
                                                    const Color(0xFFB1B1B1),
                                                iconSize: 20,
                                                menuItems: [
                                                  PopupMenuItemInfo(
                                                      label: 'Details',
                                                      value: 'details'),
                                                  PopupMenuItemInfo(
                                                      label: 'Add',
                                                      value: 'add'),
                                                  // PopupMenuItemInfo(
                                                  //     label: 'Edit',
                                                  //     value: 'edit'),
                                                  PopupMenuItemInfo(
                                                      label: 'Delete',
                                                      value: 'delete'),
                                                ],
                                                onItemSelected:
                                                    (String choice) {
                                                  if (choice == 'details') {
                                                    // Handle "Details" action
                                                  } else if (choice == 'add') {
                                                    // Handle "Add" action
                                                    WoltModalSheet.show<void>(
                                                      context: context,
                                                      pageListBuilder:
                                                          (modalSheetContext) {
                                                        return [
                                                          BookmarkEditSheet(
                                                            bookmark: link,
                                                            context:
                                                                modalSheetContext,
                                                          ).editSheet(
                                                              modalSheetContext),
                                                        ];
                                                      },
                                                    );
                                                  }
                                                  // else if (choice == 'edit') {
                                                  //   // Show a dialog with a text field for the new bookmark name
                                                  //   //TODO: Refresh when success response from server
                                                  //   showDialog(
                                                  //     context: context,
                                                  //     builder: (BuildContext
                                                  //         dialogContext) {
                                                  //       TextEditingController
                                                  //           newNameController =
                                                  //           TextEditingController();
                                                  //       return AlertDialog(
                                                  //         title: const Text(
                                                  //             'Edit Bookmark Name'),
                                                  //         content: TextField(
                                                  //           controller:
                                                  //               newNameController,
                                                  //           decoration:
                                                  //               const InputDecoration(
                                                  //                   labelText:
                                                  //                       'New Bookmark Name'),
                                                  //         ),
                                                  //         actions: <Widget>[
                                                  //           ElevatedButton(
                                                  //             child: const Text(
                                                  //                 'Cancel'),
                                                  //             onPressed: () {
                                                  //               Navigator.of(
                                                  //                       dialogContext)
                                                  //                   .pop();
                                                  //             },
                                                  //           ),
                                                  //           ElevatedButton(
                                                  //             child: const Text(
                                                  //                 'Save'),
                                                  //             onPressed:
                                                  //                 () async {
                                                  //               String
                                                  //                   newBookmarkName =
                                                  //                   newNameController
                                                  //                       .text;
                                                  //               if (newBookmarkName
                                                  //                   .isNotEmpty) {
                                                  //                 try {
                                                  //                   // Call the provider to update the bookmark name
                                                  //                   final bookmarkUpdateParams =
                                                  //                       BookmarkUpdateParameters(
                                                  //                           link.id,
                                                  //                           newBookmarkName);
                                                  //                   await ref.read(
                                                  //                       bookmarkNameUpdateProvider(bookmarkUpdateParams)
                                                  //                           .future);
                                                  //                   Navigator.of(
                                                  //                           dialogContext)
                                                  //                       .pop(); // Close the dialog
                                                  //                 } catch (error) {
                                                  //                   print(
                                                  //                       'Failed to update bookmark name: $error');
                                                  //                   // Handle the error, e.g., show an error message to the user
                                                  //                 }
                                                  //               }
                                                  //             },
                                                  //           ),
                                                  //         ],
                                                  //       );
                                                  //     },
                                                  //   );
                                                  // }
                                                  else if (choice == 'delete') {
                                                    // Handle "Remove" action
                                                    //TODO: Hide the SwipeableTile.card when remove is pressed
                                                    _deleteBookmark(link.id!);
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
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show the bottom sheet for adding a new bookmark
            showAddBookmarkDialog(context);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
