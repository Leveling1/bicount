import 'package:bicount/core/constants/transaction_types.dart';
import 'package:flutter/material.dart';

class SegmentedControlController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  String get selectedValue {
    switch (_selectedIndex) {
      case TransactionTypes.transfer:
        return TransactionTypes.transferText;
      case TransactionTypes.subscription:
        return TransactionTypes.subscriptionText;
      case TransactionTypes.addFund:
        return TransactionTypes.addFundText;
      default:
        return TransactionTypes.transferText;
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
      case TransactionTypes.transferText:
        index = TransactionTypes.transfer;
        break;
      case TransactionTypes.subscriptionText:
        index = TransactionTypes.subscription;
        break;
      case TransactionTypes.addFundText:
        index = TransactionTypes.addFund;
        break;
      default:
        index = TransactionTypes.transfer;
    }
    setSelectedIndex(index);
  }
}

class SegmentedControlWidget extends StatefulWidget {
  final SegmentedControlController controller;

  const SegmentedControlWidget({super.key, required this.controller});

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
          _buildSegment(
            TransactionTypes.transferText,
            TransactionTypes.transfer,
          ),
          _buildSegment(
            TransactionTypes.subscriptionText,
            TransactionTypes.subscription,
          ),
          _buildSegment(TransactionTypes.addFundText, TransactionTypes.addFund),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C6C6C) : Colors.transparent,
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
