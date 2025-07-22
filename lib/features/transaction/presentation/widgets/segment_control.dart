import 'package:flutter/material.dart';

class SegmentedControlController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  String get selectedValue {
    switch (_selectedIndex) {
      case 0:
        return 'Expense';
      case 1:
        return 'Income';
      case 2:
        return 'Transfer';
      default:
        return 'Transfer';
    }
  }

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setSelectedValue(String value) {
    int index;
    switch (value) {
      case 'Expense':
        index = 0;
        break;
      case 'Income':
        index = 1;
        break;
      case 'Transfer':
        index = 2;
        break;
      default:
        index = 2;
    }
    setSelectedIndex(index);
  }
}

class SegmentedControlWidget extends StatefulWidget {
  final SegmentedControlController controller;

  const SegmentedControlWidget({
    super.key,
    required this.controller,
  });

  @override
  _SegmentedControlWidgetState createState() => _SegmentedControlWidgetState();
}

class _SegmentedControlWidgetState extends State<SegmentedControlWidget> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment('Expense', 0),
          _buildSegment('Income', 1),
          _buildSegment('Transfer', 2),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    bool isSelected = widget.controller.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        widget.controller.setSelectedIndex(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C6C6C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
