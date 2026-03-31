import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:flutter/material.dart';

class SalaryOccurrenceCard extends StatelessWidget {
  const SalaryOccurrenceCard({super.key, required this.occurrence, this.onTap});

  final SalaryOccurrenceEntity occurrence;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final expectedDate = formatDate(occurrence.expectedDate);
    final amount = NumberFormatUtils.formatCurrency(
      occurrence.amount,
      currencyCode: occurrence.currency,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        occurrence.source,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppDimens.spacingSmall),
                    SalaryStatusBadge(
                      label: context.salaryOccurrenceStateLabel(
                        occurrence.state,
                      ),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingExtraSmall),
                Text(
                  context.l10n.salaryExpectedOn(expectedDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (occurrence.receivedDate != null) ...[
                  const SizedBox(height: AppDimens.spacingExtraSmall),
                  Text(
                    context.l10n.salaryReceivedOn(
                      formatDate(occurrence.receivedDate!),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppDimens.spacingMedium),
                Text(
                  amount,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    final theme = Theme.of(context).extension<OtherTheme>()!;
    if (occurrence.isReceived) {
      return theme.income ?? Theme.of(context).primaryColor;
    }
    if (occurrence.isOverdue) {
      return theme.expense ?? Theme.of(context).colorScheme.error;
    }
    if (occurrence.isDueToday) {
      return theme.companyIncome ?? Theme.of(context).primaryColor;
    }
    return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  }
}
