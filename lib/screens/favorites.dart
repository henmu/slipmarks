import 'package:flutter/material.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'This is the Search page',
          style: TextStyle(
            fontFamily: 'Inter',
            // color: Colors.white,
          ),
        ),
      ),
    );
  }
}
