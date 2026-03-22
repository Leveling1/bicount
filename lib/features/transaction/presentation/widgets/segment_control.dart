import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class SegmentedControlController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}

class SegmentedControlWidget extends StatefulWidget {
  const SegmentedControlWidget({super.key, required this.controller});

  final SegmentedControlController controller;

  @override
  State<SegmentedControlWidget> createState() => _SegmentedControlWidgetState();
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
      padding: const EdgeInsets.all(4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(context.l10n.transactionTypeTransfer, 0),
          _buildSegment(context.l10n.transactionTypeSubscription, 1),
          _buildSegment(context.l10n.transactionTypeAddFund, 2),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    final isSelected = widget.controller.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.controller.setSelectedIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C6C6C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: isSelected
              ? TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                )
              : Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
