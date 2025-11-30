import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class TransactionFilterChips extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<String> filters;

  const TransactionFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = index == selectedIndex;
          final isFirst = index == 0;
          final isLast = index == filters.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              left: isFirst ? AppDimens.paddingMedium : 0.0,
              right: isLast ? AppDimens.paddingMedium : 8.0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
