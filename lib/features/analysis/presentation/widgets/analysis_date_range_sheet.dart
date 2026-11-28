import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_range_calendar.dart';
import 'package:flutter/material.dart';

class AnalysisDateRangeSheet extends StatefulWidget {
  const AnalysisDateRangeSheet({super.key, this.initialDateRange});

  final DateTimeRange? initialDateRange;

  @override
  State<AnalysisDateRangeSheet> createState() => _AnalysisDateRangeSheetState();
}

class _AnalysisDateRangeSheetState extends State<AnalysisDateRangeSheet> {
  static final _firstDate = DateTime(1900);
  static final _lastDate = DateTime(2100, 12, 31);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  bool _controllersInitialized = false;
  bool _showCalendar = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;

    final material = MaterialLocalizations.of(context);
    final range = widget.initialDateRange;
    _startController = TextEditingController(
      text: range == null ? '' : material.formatCompactDate(range.start),
    );
    _endController = TextEditingController(
      text: range == null ? '' : material.formatCompactDate(range.end),
    );
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  String? _validateDate(String? value, {bool isEnd = false}) {
    final material = MaterialLocalizations.of(context);
    final input = value?.trim() ?? '';
    if (input.isEmpty) return context.l10n.validationFieldRequired;

    final date = material.parseCompactDate(input);
    if (date == null) return material.invalidDateFormatLabel;
    if (date.isBefore(_firstDate) || date.isAfter(_lastDate)) {
      return material.dateOutOfRangeLabel;
    }
    if (isEnd) {
      final start = material.parseCompactDate(_startController.text.trim());
      if (start != null && date.isBefore(start)) {
        return material.invalidDateRangeLabel;
      }
    }
    return null;
  }

  void _saveManualRange() {
    if (!_formKey.currentState!.validate()) return;

    final material = MaterialLocalizations.of(context);
    Navigator.pop(
      context,
      DateTimeRange(
        start: material.parseCompactDate(_startController.text.trim())!,
        end: material.parseCompactDate(_endController.text.trim())!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.analysisPeriodCustomLabel,
                  style: theme.textTheme.headlineLarge,
                ),
              ),
              Tooltip(
                message: _showCalendar
                    ? material.inputDateModeButtonLabel
                    : material.calendarModeButtonLabel,
                child: CustomIconButton(
                  icon: _showCalendar ? Icons.edit : Icons.calendar_today,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showCalendar = !_showCalendar);
                  },
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: _showCalendar
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: AppSizes.dp520),
                  child: AnalysisRangeCalendar(
                    firstDate: _firstDate,
                    lastDate: _lastDate,
                    initialRange: widget.initialDateRange,
                    onSaved: (range) => Navigator.pop(context, range),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppDimens.spacingSmall,
                      children: [
                        CustomFormField(
                          controller: _startController,
                          hint: material.dateHelpText,
                          inputType: TextInputType.datetime,
                          label: material.dateRangeStartLabel,
                          validator: _validateDate,
                        ),
                        CustomFormField(
                          controller: _endController,
                          inputType: TextInputType.datetime,
                          label: material.dateRangeEndLabel,
                          hint: material.dateHelpText,
                          validator: (value) =>
                              _validateDate(value, isEnd: true),
                        ),
                        AppDimens.spacerMedium,
                        CustomButton(
                          text: context.l10n.commonSave,
                          loading: false,
                          onPressed: _saveManualRange,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
