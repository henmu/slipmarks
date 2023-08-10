import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'package:slipmarks/services/providers.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:slipmarks/elements/sticky_action_bar_wrapper.dart';
import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/models/collections.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkEditSheet {
  final Bookmark bookmark;
  final BuildContext context;

  const BookmarkEditSheet({required this.bookmark, required this.context});

  Future<List<Collections>> fetchCollections() async {
    final url = Uri.parse("$SERVER_HOST/links");
    final accessToken = AuthService.instance.accessToken;
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
          .map((collectionJson) => Collections.fromJson(collectionJson))
          .toList();

      return res;
    } else {
      // TODO: show an error in UI instead
      throw Exception('Failed to load temporary bookmarks');
    }
  }

  Future<void> _deleteBookmark(
      String bookmarkId, ProviderContainer container) async {
    try {
      await container.read(bookmarkDeletionProvider(bookmarkId).future);
      // If successful, you can navigate back or close the bottom sheet
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting bookmark: $e');
      // Show an error message to the user
    }
  }

  WoltModalSheetPage editSheet(BuildContext modalSheetContext) {
    // Define a TextEditingController for the name TextField
    final TextEditingController nameController =
        TextEditingController(text: bookmark.name);

    // Define a ValueNotifier for the selected collection in the DropdownButton
    final ValueNotifier<String?> collectionNotifier =
        ValueNotifier<String?>('add_new_collection');

    // Define a ValueNotifier for the favorite star
    final ValueNotifier<bool> favoriteNotifier = ValueNotifier<bool>(false);

    return WoltModalSheetPage.withSingleChild(
      backgroundColor: const Color(0xFF2D2D2D),
      stickyActionBar: StickyActionBarWrapper(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(modalSheetContext).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                //Save bookmarks changes and close the bottom sheet
                //TODO: Add logic here to save changes
                Navigator.of(modalSheetContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      pageTitle: const Text('Edit Bookmark'),
      topBarTitle: const Text('Edit Bookmark'),
      closeButton: CloseButton(onPressed: Navigator.of(modalSheetContext).pop),
      mainContentPadding: const EdgeInsetsDirectional.all(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120, top: 16),
        child: Column(
          children: [
            // Edit box for the name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Bookmark Name'),
            ),
            const SizedBox(height: 8),
            // Dropdown menu for collection
            Consumer(builder: (context, ref, _) {
              final AsyncValue<List<Collections>> collectionsAsyncValue =
                  ref.watch(collectionsProvider);
              return collectionsAsyncValue.when(
                data: (collectionsList) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: collectionNotifier,
                    builder: (context, selectedCollectionId, _) {
                      return DropdownButton<String>(
                        value: selectedCollectionId,
                        onChanged: (value) {
                          // If the user selects the "Add New Collection" item,
                          // set selectedCollectionId to null to represent adding a new collection
                          if (value == 'add_new_collection') {
                            value = null;
                          }
                          collectionNotifier.value = value;
                        },
                        items: [
                          // Add the "Add New Collection" item at the beginning of the list
                          const DropdownMenuItem(
                            value: 'add_new_collection',
                            child: Text('Add New Collection'),
                          ),
                          // Add other collections to the dropdown menu
                          ...collectionsList.map((collection) {
                            return DropdownMenuItem(
                              value: collection.id,
                              child: Text(collection.name),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return Text('Error loading collections');
                },
                loading: () {
                  return CircularProgressIndicator();
                },
              );
            }),
            const SizedBox(height: 8),
            // Favorite star
            ValueListenableBuilder<bool>(
              valueListenable: favoriteNotifier,
              builder: (context, isFavorite, _) {
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    favoriteNotifier.value = !isFavorite;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // Delete button
            ElevatedButton(
              onPressed: () async {
                final container = ProviderContainer();
                await _deleteBookmark(bookmark.id!, container);
                container.dispose(); // Dispose of the container after use
              },
              child: const Text('Delete Bookmark'),
            ),
          ],
        ),
      ),
    );
  }
}
