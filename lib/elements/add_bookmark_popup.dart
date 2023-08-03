import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:flutter/material.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:slipmarks/models/bookmark.dart';
import 'package:slipmarks/services/auth_service.dart';

//TODO: Change to using wolt model sheet

class AddBookmarkBottomSheet extends StatefulWidget {
  @override
  _AddBookmarkBottomSheetState createState() => _AddBookmarkBottomSheetState();
}

class _AddBookmarkBottomSheetState extends State<AddBookmarkBottomSheet> {
  TextEditingController urlController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D2D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
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
                    final completer = Completer();
                    completer.future.whenComplete(() {
                      Navigator.of(context).pop();
                    }); // Close the bottom sheet
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
    // if (url.startsWith('//')) {
    //   // Append the protocol manually
    //   url = 'https:$url';
    // }

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final linkTags = document.getElementsByTagName('link');

      for (var tag in linkTags) {
        final relAttribute = tag.attributes['rel'];
        final hrefAttribute = tag.attributes['href'];

        if ((relAttribute == 'shortcut icon' || relAttribute == 'icon') &&
            hrefAttribute != null &&
            hrefAttribute.isNotEmpty) {
          // Combine the URL to get the full favicon URL
          String faviconUrl = Uri.parse(hrefAttribute).toString();

          // Check if the favicon URL is still protocol-relative
          if (faviconUrl.startsWith('//')) {
            // Append the protocol manually again
            faviconUrl = 'https:$faviconUrl';
          }

          // Return the found favicon URL
          return faviconUrl;
        }
      }
    }
  } catch (e) {
    print('Error fetching favicon URL: $e');
  }

  // Return null if no favicon is found or any errors occur
  return null;
}

void showAddBookmarkBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          // To prevent tapping on the bottom sheet itself from closing it
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: AddBookmarkBottomSheet(),
          ),
        ),
      );
    },
  );
}
