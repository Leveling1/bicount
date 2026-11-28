import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showAnalysisContactCategories(
  BuildContext context,
  AnalysisChart chart,
) async {
  final bloc = context.read<AnalysisBloc>();
  final selection = bloc.categorySelection(chart);
  if (selection == null) return;

  await showCustomBottomSheet<void>(
    context: context,
    minHeight: 0,
    scrollEnabled: false,
    horizontalPadding: AppDimens.paddingMedium,
    child: AnalysisContactCategorySheet(
      chart: chart,
      selection: selection,
      onSave: (selected, bothCharts) => bloc.saveCategorySelection(
        original: selection,
        chart: chart,
        selected: selected,
        bothCharts: bothCharts,
      ),
    ),
  );
}

class AnalysisContactCategorySheet extends StatefulWidget {
  const AnalysisContactCategorySheet({
    super.key,
    required this.chart,
    required this.selection,
    required this.onSave,
  });

  final AnalysisChart chart;
  final AnalysisCategorySelection selection;
  final Future<void> Function(Set<String> selected, bool bothCharts) onSave;

  @override
  State<AnalysisContactCategorySheet> createState() =>
      _AnalysisContactCategorySheetState();
}

class _AnalysisContactCategorySheetState
    extends State<AnalysisContactCategorySheet> {
  late final _selected = {...widget.selection.selected};
  final _searchController = TextEditingController();
  var _query = '';
  var _bothCharts = false;
  var _saving = false;
  var _failed = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onSave(Set.unmodifiable(_selected), _bothCharts);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final contacts = widget.selection.contacts;
    final matches = contacts.where((friend) {
      return friend.username.toLowerCase().contains(_query) ||
          friend.email.toLowerCase().contains(_query);
    }).toList();
    final chartLabel = widget.chart == AnalysisChart.income
        ? l10n.analysisIncome
        : l10n.analysisExpenses;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingSmall,
      children: [
        Text(
          l10n.analysisContactCategories,
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        Text(chartLabel, style: theme.textTheme.bodyMedium),
        if (contacts.isEmpty)
          Flexible(
            child: SingleChildScrollView(child: Text(l10n.analysisNoContacts)),
          )
        else ...[
          Flexible(
            child: CustomScrollView(
              shrinkWrap: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: CustomSearchField(
                    controller: _searchController,
                    hintText: l10n.analysisSearchContacts,
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BicountPressable.control(
                    enabled: !(_saving),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.analysisAddContactsToBothCharts,
                        style: theme.textTheme.bodySmall,
                      ),
                      value: _bothCharts,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _bothCharts = value),
                    ),
                  ),
                ),
                if (matches.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingMedium),
                      child: Text(l10n.friendsSearchEmpty),
                    ),
                  ),
                SliverList.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final friend = matches[index];
                    return BicountPressable.control(
                      enabled: !(_saving),
                      child: CheckboxListTile(
                        key: ValueKey(friend.sid),
                        contentPadding: EdgeInsets.zero,
                        title: Text(friend.username),
                        subtitle: friend.email.isEmpty
                            ? null
                            : Text(friend.email),
                        value: _selected.contains(friend.sid),
                        onChanged: _saving
                            ? null
                            : (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selected.add(friend.sid);
                                  } else {
                                    _selected.remove(friend.sid);
                                  }
                                });
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_failed)
            Text(
              l10n.analysisContactCategoriesSaveError,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          CustomButton(
            text: l10n.commonSave,
            onPressed: _save,
            loading: _saving,
          ),
        ],
        AppDimens.spacerSmall,
      ],
    );
  }
}
