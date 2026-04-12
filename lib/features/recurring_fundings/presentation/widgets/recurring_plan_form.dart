import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/update_recurring_transfert_request_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecurringPlanForm extends StatefulWidget {
  const RecurringPlanForm({super.key, required this.summary});

  final RecurringPlanSummaryEntity summary;

  @override
  State<RecurringPlanForm> createState() => _RecurringPlanFormState();
}

class _RecurringPlanFormState extends State<RecurringPlanForm> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _currency = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late int _frequency;

  @override
  void initState() {
    super.initState();
    final recurringTransfert = widget.summary.recurringTransfert;
    _title.text = recurringTransfert.title;
    _note.text = recurringTransfert.note;
    _amount.text = _formatAmount(recurringTransfert.amount);
    _currency.text = recurringTransfert.currency;
    _date.text = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.tryParse(recurringTransfert.startDate) ?? DateTime.now());
    _frequency = _normalizeFrequency(recurringTransfert.frequency);
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _amount.dispose();
    _currency.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomAmountField(amount: _amount, currency: _currency),
          AppDimens.spacerMedium,
          CustomFormField(
            controller: _date,
            label: context.l10n.commonDate,
            hint: context.l10n.commonDateHint,
            isDate: true,
          ),
          AppDimens.spacerMedium,
          CustomFormField(
            controller: _title,
            label: context.l10n.commonTitle,
            hint: context.l10n.transferEnterTransactionName,
          ),
          AppDimens.spacerMedium,
          _FrequencySelector(
            selected: _frequency,
            onChanged: (value) => setState(() => _frequency = value),
          ),
          AppDimens.spacerMedium,
          CustomFormField(
            controller: _note,
            label: context.l10n.commonNote,
            hint: context.l10n.commonPlaceholderNote,
            enableValidator: false,
          ),
          AppDimens.spacerExtraLarge,
          FilledButton(
            onPressed: _submit,
            child: Text(context.l10n.commonSave),
          ),
          AppDimens.spacerMedium,
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      return;
    }

    context.read<RecurringTransfertBloc>().add(
      UpdateRecurringPlanRequested(
        UpdateRecurringTransfertRequestEntity(
          recurringTransfertId:
              widget.summary.recurringTransfert.recurringTransfertId ?? '',
          title: _title.text.trim(),
          note: _note.text.trim(),
          amount: amount,
          currency: _currency.text.trim(),
          frequency: _frequency,
          startDate: _date.text.trim(),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toString();
  }

  int _normalizeFrequency(int frequency) {
    return switch (frequency) {
      4 => Frequency.quarterly,
      5 => Frequency.yearly,
      _ => frequency,
    };
  }
}

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _frequencies = [
    Frequency.weekly,
    Frequency.monthly,
    Frequency.quarterly,
    Frequency.yearly,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.commonFrequency,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          spacing: AppDimens.spacingSmall,
          children: _frequencies.map((frequency) {
            return CustomChoiceChip(
              label: context.frequencyLabel(frequency),
              selected: selected == frequency,
              onSelected: (_) => onChanged(frequency),
            );
          }).toList(),
        ),
      ],
    );
  }
}
