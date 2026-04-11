import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/custom_button.dart';

class SalaryOccurrenceSheet extends StatefulWidget {
  const SalaryOccurrenceSheet({
    super.key,
    required this.occurrence,
    required this.isLoading,
    required this.onConfirmPressed,
    required this.onAutomaticModePressed,
  });

  final SalaryOccurrenceEntity occurrence;
  final bool isLoading;
  final ValueChanged<double> onConfirmPressed;
  final ValueChanged<double> onAutomaticModePressed;

  @override
  State<SalaryOccurrenceSheet> createState() => _SalaryOccurrenceSheetState();
}

class _SalaryOccurrenceSheetState extends State<SalaryOccurrenceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.occurrence.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final rawValue = _amountController.text.trim();
    if (rawValue.isEmpty) {
      return null;
    }
    return double.tryParse(rawValue.replaceAll(' ', '').replaceAll(',', '.'));
  }

  void _submit(ValueChanged<double> callback) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      return;
    }
    callback(amount);
  }

  @override
  Widget build(BuildContext context) {
    final occurrence = widget.occurrence;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            occurrence.source,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          SalaryStatusBadge(
            label: context.salaryOccurrenceStateLabel(occurrence.state),
            color: Theme.of(context).primaryColor,
          ),
          DetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormatUtils.formatCurrency(
                    occurrence.amount,
                    currencyCode: occurrence.currency,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppDimens.spacingSmall),
                Text(
                  context.l10n.salaryExpectedOn(
                    formatDate(occurrence.expectedDate),
                  ),
                ),
                if (occurrence.receivedDate != null) ...[
                  const SizedBox(height: AppDimens.spacingExtraSmall),
                  Text(
                    context.l10n.salaryReceivedOn(
                      formatDate(occurrence.receivedDate!),
                    ),
                  ),
                ],
                if (occurrence.note?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppDimens.spacingSmall),
                  Text(occurrence.note!),
                ],
              ],
            ),
          ),
          if (occurrence.needsAttention && occurrence.requiresConfirmation) ...[
            const SizedBox(height: AppDimens.spacingMedium),
            Text(
              context.l10n.commonAmount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,\. ]')),
              ],
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').trim().replaceAll(' ', '').replaceAll(',', '.'),
                );
                if (amount == null || amount <= 0) {
                  return context.l10n.validationFieldRequired;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: occurrence.amount
                    .toStringAsFixed(2)
                    .replaceAll('.', ','),
                suffixText: occurrence.currency,
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            Text(
              context.l10n.transactionSetExactAmountReceived,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimens.spacingMedium),
            CustomButton(
              text: context.l10n.salaryConfirmPaymentCta,
              onPressed: () => _submit(widget.onConfirmPressed),
              loading: widget.isLoading,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            CustomOutlinedButton(
              onPressed: () => _submit(widget.onAutomaticModePressed),
              text: context.l10n.salaryKeepAutomaticCta,
              loading: widget.isLoading,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            Text(
              occurrence.remindersEnabled
                  ? context.l10n.salaryAutomaticModeHelper
                  : context.l10n.salaryReminderDisabledHelper,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          AppDimens.spacerMedium,
        ],
      ),
    );
  }
}
