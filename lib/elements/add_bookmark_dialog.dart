import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/helpers/favicon_finder.dart';
import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/services/auth_service.dart';

class AddBookmarkDialog extends StatefulWidget {
  @override
  _AddBookmarkDialogState createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  TextEditingController urlController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Bookmark',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Bookmark Name',
              ),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Bookmark URL',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String url = urlController.text;

                // Fetch the favicon URL from the provided URL
                String? faviconUrl = await fetchFaviconUrl(urlController.text);

                // Create a new Bookmark object
                Bookmark newBookmark = Bookmark(
                  name: name,
                  url: url,
                  iconUrl: faviconUrl,
                );

                String jsonData = jsonEncode(newBookmark.toJson());

                // Print the JSON data to the console
                print(jsonData);

                try {
                  // Perform your API request here to post the new bookmark
                  final url = Uri.parse("$SERVER_HOST/bookmarks");
                  final accessToken = AuthService.instance.accessToken;
                  final response = await http.post(
                    url,
                    headers: {
                      'Authorization': 'Bearer $accessToken',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(newBookmark.toJson()),
                  );

                  // Check the response and handle any errors if needed
                  if (response.statusCode == 201) {
                    // Bookmark creation success
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    // Bookmark creation failed
                    print('Response Code: ${response.statusCode}');
                    print('Response Content: ${response.body}');
                    print('Failed to create a new bookmark');
                    // Show an error message to the user
                  }
                } catch (e) {
                  // Error handling for the API request
                  print('Error creating bookmark: $e');
                  // Show an error message to the user
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> fetchFaviconUrl(String url) async {
  try {
    // Use FaviconFinder to get the best favicon URL for the provided URL
    Favicon? favicon = await FaviconFinder.getBest(url);

    // Return the favicon URL if found
    return favicon?.url;
  } catch (e) {
    print('Error fetching favicon URL: $e');
  }

  // Return null if no favicon is found or any errors occur
  return null;
}

void showAddBookmarkDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: AddBookmarkDialog(),
        ),
      );
    },
  );
}
