import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:flutter/material.dart';

class AnalysisPeriodSelector extends StatelessWidget {
  const AnalysisPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  final AnalysisPeriod selectedPeriod;
  final ValueChanged<AnalysisPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalysisPeriod.values.map((period) {
          final selected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomChoiceChip(
              label: context.analysisPeriodLabel(period),
              selected: selected,
              onSelected: (_) => onSelected(period),
            ),
          );
        }).toList(),
      ),
    );
  }
}
