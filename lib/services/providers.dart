import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:slipmarks/helpers/constants.dart';
import 'dart:convert';

import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/models/collections.dart';
import 'package:slipmarks/models/devices.dart';

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

final bookmarkNameUpdateProvider =
    FutureProviderFamily<void, BookmarkUpdateParameters>(
  (ref, params) async {
    final url = Uri.parse('$SERVER_HOST/bookmarks/${params.bookmarkId}');
    final accessToken = AuthService.instance.accessToken;

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': params.newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update the bookmark name');
    }
  },
);

class BookmarkUpdateParameters {
  final String? bookmarkId;
  final String newName;

  BookmarkUpdateParameters(this.bookmarkId, this.newName);
}

final collectionProvider = FutureProvider<List<Collections>>((ref) async {
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

Future<String> createNewCollection(String collectionName) async {
  final url = Uri.parse("$SERVER_HOST/collections");
  final accessToken = AuthService.instance.accessToken;
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    },
    body: json.encode({'name': collectionName}),
  );

  if (response.statusCode == 201) {
    final newCollectionId = json.decode(utf8.decode(response.bodyBytes))['id'];
    return newCollectionId;
  } else {
    throw Exception('Failed to create new collection');
  }
}

final newCollectionIdProvider =
    FutureProviderFamily<String, String>((ref, collectionName) async {
  final newCollectionId = await createNewCollection(collectionName);
  return newCollectionId;
});

Future<bool> addBookmarkToCollection(
    String collectionId, String? bookmarkId) async {
  final url = Uri.parse("$SERVER_HOST/collections/$collectionId/bookmarks");
  final accessToken = AuthService.instance.accessToken;

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    },
    body: json.encode([collectionId, bookmarkId]),
  );

  if (response.statusCode == 200) {
    // Bookmark added successfully
    return true;
  } else {
    throw Exception('Failed to add bookmark to collection');
  }
}

final collectionDeletionProvider =
    FutureProvider.family<void, String>((ref, collectionId) async {
  final url = Uri.parse('$SERVER_HOST/collections/$collectionId');
  final accessToken = AuthService.instance.accessToken;
  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete the bookmark');
  }
});

final bookmarkAdditionProvider =
    FutureProviderFamily<void, BookmarkAdditionParameters>((ref, params) async {
  final newCollectionId = params.collectionId;
  final bookmarkId = params.bookmarkId;

  final bookmarkAdded =
      await addBookmarkToCollection(newCollectionId, bookmarkId);
  if (!bookmarkAdded) {
    throw Exception('Failed to add bookmark to the collection');
  }
});

class BookmarkAdditionParameters {
  final String collectionId;
  final String? bookmarkId;

  BookmarkAdditionParameters(this.collectionId, this.bookmarkId);
}

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

final devicesProvider = FutureProvider<List<Devices>>((ref) async {
  final url = Uri.parse("$SERVER_HOST/devices");
  final accessToken = AuthService.instance.accessToken;
  final response =
      await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

  if (response.statusCode == 200) {
    final res = (json.decode(utf8.decode(response.bodyBytes)) as List)
        .map((collectionJson) => Devices.fromJson(collectionJson))
        .toList();

    return res;
  } else {
    throw Exception('Failed to load collections');
  }
});
