import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:flutter/material.dart';

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({
    super.key,
    required this.summary,
    required this.openLabel,
    required this.overdueLabel,
    required this.onTap,
  });

  final DebtSummaryEntity summary;
  final String openLabel;
  final String overdueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = summary.isReceivable
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        child: DetailsCard(
          isMargin: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      summary.debt.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingSmall,
                      vertical: AppDimens.paddingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusFull,
                      ),
                    ),
                    child: Text(
                      summary.isOverdue ? overdueLabel : openLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingExtraSmall),
              Text(
                summary.counterpartyName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(
                NumberFormatUtils.formatCurrency(
                  summary.debt.remainingAmount,
                  currencyCode: summary.debt.currency,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimens.spacingExtraSmall),
              Text(
                summary.dueDate == null
                    ? '-'
                    : formatDateWithoutYear(summary.dueDate!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
