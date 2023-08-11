import 'package:flutter/material.dart';

//TODO: Add rounded edges to the popupmenu
class FilterDropDown extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected;

  FilterDropDown({
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  _FilterDropDownState createState() => _FilterDropDownState();
}

class _FilterDropDownState extends State<FilterDropDown> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _showPopupMenu(details.globalPosition);
      },
      child: Row(
        children: [
          Row(
            children: [
              Text(
                widget.selectedOption,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPopupMenu(Offset tapPosition) async {
    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: widget.options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );

    if (selectedValue != null) {
      widget.onOptionSelected(selectedValue);
    }
  }
}
