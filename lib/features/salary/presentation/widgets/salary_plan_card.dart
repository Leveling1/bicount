import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/salary/domain/entities/salary_plan_summary_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:flutter/material.dart';

class SalaryPlanCard extends StatelessWidget {
  const SalaryPlanCard({
    super.key,
    required this.plan,
    required this.currencyCode,
  });

  final SalaryPlanSummaryEntity plan;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMedium),
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plan.recurringFunding.source,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppDimens.spacingSmall),
              SalaryStatusBadge(
                label: plan.requiresConfirmation
                    ? context.l10n.salaryModeConfirm
                    : context.l10n.salaryModeAutomatic,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          Text(
            NumberFormatUtils.formatCurrency(
              plan.recurringFunding.amount,
              currencyCode: plan.recurringFunding.currency,
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          Wrap(
            spacing: AppDimens.spacingSmall,
            runSpacing: AppDimens.spacingSmall,
            children: [
              Text(
                context.l10n.salaryNextPaydayValue(
                  plan.nextExpectedDate == null
                      ? '-'
                      : formatDateWithoutYear(plan.nextExpectedDate!),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (plan.requiresConfirmation)
                Text(
                  context.l10n.salaryReminderStatusValue(
                    plan.remindersEnabled
                        ? context.l10n.statusActive
                        : context.l10n.statusInactive,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (plan.requiresConfirmation && plan.totalAttentionCount > 0)
                Text(
                  context.l10n.salaryArrearsValue(
                    NumberFormatUtils.compactCurrency(
                      plan.outstandingReferenceAmount,
                      currencyCode: currencyCode,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
