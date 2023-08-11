import 'package:flutter/material.dart';

class BookmarkPopupMenu extends StatelessWidget {
  final List<PopupMenuItemInfo> menuItems;
  final Function(String) onItemSelected;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const BookmarkPopupMenu({
    super.key,
    required this.onItemSelected,
    required this.menuItems,
    required this.icon,
    this.iconColor = const Color(0xFFFFFFFF),
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open your custom menu when tapped
        _showCustomPopupMenu(context);
      },
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
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
      items: menuItems.map((item) {
        return PopupMenuItem<String>(
          value: item.value,
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(item.label),
          ),
        );
      }).toList(),
    ).then(
      (value) {
        if (value != null) {
          onItemSelected(value);
        }
      },
    );
  }
}

class PopupMenuItemInfo {
  final String label;
  final String value;

  PopupMenuItemInfo({
    required this.label,
    required this.value,
  });
}
