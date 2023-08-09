import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:slipmarks/helpers/constants.dart';
import 'dart:convert';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/models/collections.dart';

import 'package:slipmarks/services/auth_service.dart';

final bookmarksFutureProvider = FutureProvider<List<Bookmark>>((ref) async {
  final url = Uri.parse("$SERVER_HOST/links");
  final accessToken = AuthService.instance.accessToken;
  final response =
      await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
        .map((bookmarkJson) => Bookmark.fromJson(bookmarkJson))
        .toList();

    return res;
  } else {
    throw Exception('Failed to load temporary bookmarks');
  }
});

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<Bookmark>>(
  (ref) => BookmarksNotifier(),
);

class BookmarksNotifier extends StateNotifier<List<Bookmark>> {
  BookmarksNotifier() : super([]);

  void updateBookmarks(List<Bookmark> newBookmarks) {
    state = newBookmarks;
  }
}

final collectionsProvider = FutureProvider<List<Collections>>((ref) async {
  final url = Uri.parse("$SERVER_HOST/collections");
  final accessToken = AuthService.instance.accessToken;
  final response =
      await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
        .map((collectionJson) => Collections.fromJson(collectionJson))
        .toList();

    return res;
  } else {
    throw Exception('Failed to load collections');
  }
});

final bookmarksByCollectionProvider =
    FutureProviderFamily<List<Bookmark>, String>((ref, collectionId) async {
  final url = Uri.parse("$SERVER_HOST/collections/$collectionId/bookmarks");
  final accessToken = AuthService.instance.accessToken;
  final response =
      await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
        .map((bookmarkJson) => Bookmark.fromJson(bookmarkJson))
        .toList();

    return res;
  } else {
    throw Exception('Failed to load bookmarks for collection');
  }
});

final bookmarkDeletionProvider =
    FutureProvider.family<void, String>((ref, bookmarkId) async {
  final url = Uri.parse('$SERVER_HOST/bookmarks/$bookmarkId');
  final accessToken = AuthService.instance.accessToken;
  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete the bookmark');
  }
});
