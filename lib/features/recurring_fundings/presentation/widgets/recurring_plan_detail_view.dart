import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_status_badge.dart';
import 'package:bicount/features/subscription/presentation/widgets/meta_pill.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_actions.dart';
import 'package:flutter/material.dart';

class RecurringPlanDetailView extends StatelessWidget {
  const RecurringPlanDetailView({
    super.key,
    required this.scope,
    required this.data,
    required this.summary,
    required this.isLoading,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTerminatePressed,
  });

  final RecurringPlanScope scope;
  final MainEntity data;
  final RecurringPlanSummaryEntity summary;
  final bool isLoading;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onTerminatePressed;

  @override
  Widget build(BuildContext context) {
    final recurringTransfert = summary.recurringTransfert;
    final statusColor = summary.isActive
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor;
    final counterpartyName = _resolveCounterpartyName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailActions(
          iconSize: 20,
          isLoading: isLoading,
          onDeletePressed: onDeletePressed,
          onEditPressed: onEditPressed,
        ),
        Text(
          recurringTransfert.title,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppDimens.spacingSmall),
        SalaryStatusBadge(
          label: summary.isActive
              ? context.l10n.statusActive
              : context.l10n.statusInactive,
          color: statusColor,
        ),
        const SizedBox(height: AppDimens.spacingMedium),
        DetailsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NumberFormatUtils.formatCurrency(
                  recurringTransfert.amount,
                  currencyCode: recurringTransfert.currency,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(counterpartyName),
              const SizedBox(height: AppDimens.spacingSmall),
              Wrap(
                spacing: AppDimens.spacingSmall,
                runSpacing: AppDimens.spacingSmall,
                children: [
                  MetaPill(
                    icon: Icons.event_outlined,
                    label: context.l10n.salaryNextPaydayTitle,
                    value: summary.nextExpectedDate == null
                        ? '-'
                        : formatDate(summary.nextExpectedDate!),
                  ),
                  MetaPill(
                    icon: Icons.insights_outlined,
                    label: context.l10n.analysisMonthlyLoad,
                    value: NumberFormatUtils.compactCurrency(
                      summary.monthlyReferenceAmount,
                      currencyCode: data.referenceCurrencyCode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DetailsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.commonFrequency}: ${context.frequencyLabel(recurringTransfert.frequency)}',
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(
                '${context.l10n.recurringPlanRecordedTotalLabel}: ${NumberFormatUtils.compactCurrency(summary.totalRecordedReferenceAmount, currencyCode: data.referenceCurrencyCode)}',
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(
                '${context.l10n.recurringPlanRecordedCountLabel}: ${summary.recordedCount}',
              ),
              if (recurringTransfert.note.isNotEmpty) ...[
                const SizedBox(height: AppDimens.spacingSmall),
                Text('${context.l10n.commonNote}: ${recurringTransfert.note}'),
              ],
            ],
          ),
        ),
        if (onTerminatePressed != null) ...[
          const SizedBox(height: AppDimens.spacingMedium),
          CustomOutlinedButton(
            onPressed: onTerminatePressed!,
            text: context.l10n.recurringPlanTerminateCta,
            loading: isLoading,
          ),
        ],
        AppDimens.spacerMedium,
      ],
    );
  }

  String _resolveCounterpartyName() {
    final partyId = scope == RecurringPlanScope.charge
        ? summary.recurringTransfert.beneficiaryId
        : summary.recurringTransfert.senderId;
    if (partyId == data.user.uid) {
      return data.user.username;
    }

    for (final friend in data.friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        return friend.username;
      }
    }

    return partyId;
  }
}
