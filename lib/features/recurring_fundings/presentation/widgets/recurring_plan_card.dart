import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:bicount/features/subscription/presentation/widgets/meta_pill.dart';
import 'package:flutter/material.dart';

class RecurringPlanCard extends StatelessWidget {
  const RecurringPlanCard({
    super.key,
    required this.scope,
    required this.summary,
    required this.referenceCurrencyCode,
    required this.onTap,
  });

  final RecurringPlanScope scope;
  final RecurringPlanSummaryEntity summary;
  final String referenceCurrencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                        summary.recurringTransfert.title,
                        maxLines: AppDimens.maxLinesShort,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppDimens.spacingSmall),
                    SalaryStatusBadge(
                      label: summary.isActive
                          ? context.l10n.statusActive
                          : context.l10n.statusInactive,
                      color: summary.isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingExtraSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (summary.nextExpectedDate != null) ...[
                      MetaPill(
                        icon: Icons.event_outlined,
                        label: context.l10n.salaryNextPaydayTitle,
                        value: summary.nextExpectedDate == null
                            ? '-'
                            : formatDateWithoutYear(summary.nextExpectedDate!),
                      ),
                    ],
                    Text(
                      context.frequencyLabel(
                        summary.recurringTransfert.frequency,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingSmall),
                Text(
                  NumberFormatUtils.formatCurrency(
                    summary.recurringTransfert.amount,
                    currencyCode: summary.recurringTransfert.currency,
                  ),
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
}
