import 'package:flutter/material.dart';
import 'package:slipmarks/models/collections.dart';
import 'package:slipmarks/screens/login.dart';
import 'package:slipmarks/services/auth_service.dart';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:http/http.dart' as http;
import 'package:slipmarks/services/providers.dart';

import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:slipmarks/bookmarkEditSheet.dart';

import 'package:slipmarks/elements/custom_Dismissable_Card.dart';
import 'package:slipmarks/bookmarkEditSheet.dart';

import 'package:slipmarks/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                      child: CustomDismissableCard(
                        // borderRadius: 10,
                        // color: const Color(0xFF282828),
                        // color: Colors.white,
                        key: UniqueKey(),
                        // swipeThreshold: 0.9,
                        // direction: SwipeDirection.horizontal,
                        // onSwiped: (_) {
                        // },
                        // backgroundBuilder: (context, direction, progress) {
                        //   if (direction == SwipeDirection.endToStart) {
                        //     return Container(
                        //       color: Colors.red,
                        //     );
                        //   } else if (direction == SwipeDirection.startToEnd) {
                        //     return Container(
                        //       color: Colors.green,
                        //     );
                        //   }
                        //   return Container();
                        // },
                        // horizontalPadding: 16,
                        // verticalPadding: 8,
                        // shadow: BoxShadow(
                        //   color: Colors.black.withOpacity(0.35),
                        //   blurRadius: 4,
                        //   offset: const Offset(2, 2),
                        // ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
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
                              // ... other properties ...
                            );
                          } else if (direction == DismissDirection.endToStart) {
                            // Handle left swipe
                          }
                        },
                        onUpSwipe: () {
                          // Handle upward swipe
                        },
                        onDownSwipe: () {
                          // Handle downward swipe
                        },
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
    );
  }
}
