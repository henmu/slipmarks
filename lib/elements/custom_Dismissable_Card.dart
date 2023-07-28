import 'package:flutter/material.dart';

class CustomDismissableCard extends StatelessWidget {
  const CustomDismissableCard({
    Key? key,
    required this.onDismissed,
    required this.child,
    required this.onUpSwipe,
    required this.onDownSwipe,
  }) : super(key: key);

  final Function(DismissDirection) onDismissed;
  final Widget child;
  final VoidCallback onUpSwipe;
  final VoidCallback onDownSwipe;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.horizontal,
      onDismissed: onDismissed,
      background: _buildBackground(),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            // Detect upward swipe
            onUpSwipe();
          } else if (details.delta.dy > 0) {
            // Detect downward swipe
            onDownSwipe();
          }
        },
        child: child,
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
