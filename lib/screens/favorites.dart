import 'package:flutter/material.dart';

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
