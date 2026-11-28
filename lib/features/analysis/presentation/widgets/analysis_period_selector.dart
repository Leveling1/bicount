import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_date_range_sheet.dart';
import 'package:flutter/material.dart';

class AnalysisPeriodSelector extends StatefulWidget {
  const AnalysisPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  final AnalysisPeriod selectedPeriod;
  final ValueChanged<AnalysisPeriod> onSelected;

  @override
  State<AnalysisPeriodSelector> createState() => _AnalysisPeriodSelectorState();
}

class _AnalysisPeriodSelectorState extends State<AnalysisPeriodSelector> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant AnalysisPeriodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final range = widget.selectedPeriod.dateRange;
    if (range == null || range == oldWidget.selectedPeriod.dateRange) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.pixels < position.maxScrollExtent) {
        _scrollController.jumpTo(position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final range = await showCustomBottomSheet<DateTimeRange>(
      context: context,
      minHeight: 0,
      horizontalPadding: 0,
      scrollEnabled: false,
      child: AnalysisDateRangeSheet(
        initialDateRange: widget.selectedPeriod.dateRange,
      ),
    );
    if (range != null && mounted) {
      widget.onSelected(AnalysisPeriod.custom(range));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = widget.selectedPeriod;
    final isCustom = selectedPeriod.dateRange != null;
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Row(
        spacing: AppDimens.spacingSmall,
        children: [
          for (final period in AnalysisPeriod.presets)
            CustomChoiceChip(
              label: period.label(context),
              selected: period == selectedPeriod,
              onSelected: (_) => widget.onSelected(period),
            ),
          CustomChoiceChip(
            label: isCustom
                ? selectedPeriod.label(context)
                : context.l10n.analysisPeriodCustomLabel,
            selected: isCustom,
            onSelected: (_) => _pickPeriod(),
          ),
        ],
      ),
    );
  }
}
