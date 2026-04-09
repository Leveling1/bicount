import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
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
            child: CustomChoiceChip(
              label: context.graphPeriodLabel(period),
              selected: selected,
              onSelected: (_) => onSelected(period),
            ),
          );
        }).toList(),
      ),
    );
  }
}
