import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';

class SalaryOccurrenceSheet extends StatelessWidget {
  const SalaryOccurrenceSheet({
    super.key,
    required this.occurrence,
    required this.isLoading,
    required this.onConfirmPressed,
    required this.onAutomaticModePressed,
  });

  final SalaryOccurrenceEntity occurrence;
  final bool isLoading;
  final VoidCallback onConfirmPressed;
  final VoidCallback onAutomaticModePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          CustomButton(
            text: context.l10n.salaryConfirmPaymentCta,
            onPressed: onConfirmPressed,
            loading: isLoading,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          CustomOutlinedButton(
            onPressed: onAutomaticModePressed,
            text: context.l10n.salaryKeepAutomaticCta,
            loading: isLoading,
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
    );
  }
}
