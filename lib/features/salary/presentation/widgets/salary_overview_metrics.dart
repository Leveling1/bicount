import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/salary/domain/entities/salary_dashboard_entity.dart';
import 'package:flutter/material.dart';

class SalaryOverviewMetrics extends StatelessWidget {
  const SalaryOverviewMetrics({
    super.key,
    required this.dashboard,
    required this.currencyCode,
  });

  final SalaryDashboardEntity dashboard;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final incomeColor = Theme.of(context).extension<OtherTheme>()!.income!;
    final expenseColor = Theme.of(context).extension<OtherTheme>()!.expense!;
    final primaryColor = Theme.of(context).primaryColor;

    return Wrap(
      spacing: AppDimens.spacingMedium,
      runSpacing: AppDimens.spacingMedium,
      children: [
        _MetricCard(
          title: context.l10n.salaryOverdueTitle,
          value: NumberFormatUtils.compactCurrency(
            dashboard.overdueAmount,
            currencyCode: currencyCode,
          ),
          helper: '${dashboard.overdueCount} ${context.l10n.commonItems}',
          color: expenseColor,
        ),
        _MetricCard(
          title: context.l10n.salaryDueTodayTitle,
          value: NumberFormatUtils.compactCurrency(
            dashboard.dueTodayAmount,
            currencyCode: currencyCode,
          ),
          helper: '${dashboard.dueTodayCount} ${context.l10n.commonItems}',
          color: incomeColor,
        ),
        _MetricCard(
          title: context.l10n.salaryNextPaydayTitle,
          value: dashboard.nextExpectedDate == null
              ? '-'
              : formatDateWithoutYear(dashboard.nextExpectedDate!),
          helper: '${dashboard.plans.length} ${context.l10n.salaryPlansTitle}',
          color: primaryColor,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.color,
  });

  final String title;
  final String value;
  final String helper;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      child: DetailsCard(
        isMargin: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimens.spacingSmall),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: AppDimens.spacingExtraSmall),
            Text(helper, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
