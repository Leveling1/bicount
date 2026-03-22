import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:flutter/material.dart';

class GraphPeriodSelector extends StatelessWidget {
  const GraphPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  final GraphPeriod selectedPeriod;
  final ValueChanged<GraphPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: GraphPeriod.values.map((period) {
          final selected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(context.graphPeriodLabel(period)),
              selected: selected,
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.16),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              onSelected: (_) => onSelected(period),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }
}
