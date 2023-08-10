import 'package:flutter/material.dart';

class BookmarkPopupMenu extends StatelessWidget {
  final Function(String) onItemSelected;

  const BookmarkPopupMenu({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open your custom menu when tapped
        _showCustomPopupMenu(context);
      },
      child: const Icon(
        Icons.more_horiz,
        color: Color(0xFFB1B1B1),
        size: 20,
      ),
    );
  }

  void _showCustomPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'details',
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text('Details'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'add',
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text('Add'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'favorite',
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text('Favorite'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text('delete'),
          ),
        ),
      ],
    ).then(
      (value) {
        if (value != null) {
          onItemSelected(value);
        }
      },
    );
  }
}
