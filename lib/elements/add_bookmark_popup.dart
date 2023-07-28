import 'dart:ui';

import 'package:flutter/material.dart';

//TODO: Change to using wolt model sheet

class AddBookmarkBottomSheet extends StatefulWidget {
  @override
  _AddBookmarkBottomSheetState createState() => _AddBookmarkBottomSheetState();
}

class _AddBookmarkBottomSheetState extends State<AddBookmarkBottomSheet> {
  TextEditingController urlController = TextEditingController();

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
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Bookmark URL',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Save the new bookmark and close the bottom sheet
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
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
