import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSalaryStatusCard extends StatelessWidget {
  const HomeSalaryStatusCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final MainEntity data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;
    final dashboard = const SalaryDashboardBuilder().build(
      recurringFundings: data.recurringFundings,
      accountFundings: data.accountFundings,
      currencyConfig: currencyConfig,
    );
    if (!dashboard.hasPlans) {
      return const SizedBox.shrink();
    }

    final accentColor = dashboard.hasAttention
        ? Theme.of(context).extension<OtherTheme>()!.expense!
        : Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.salaryHomeCardTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimens.spacingSmall),
                      Text(
                        dashboard.hasAttention
                            ? context.l10n.salaryHomeCardAttention(
                          NumberFormatUtils.compactCurrency(
                            dashboard.totalOutstandingAmount,
                            currencyCode: data.referenceCurrencyCode,
                          ),
                        )
                            : context.l10n.salaryHomeCardNext(
                          dashboard.nextExpectedDate == null
                              ? '-'
                              : formatDateWithoutYear(
                            dashboard.nextExpectedDate!,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.spacingExtraSmall),
                      Text(
                        dashboard.hasAttention
                            ? context.l10n.salaryHomeCardCount(
                          dashboard.overdueCount + dashboard.dueTodayCount,
                        )
                            : context.l10n.salaryPlansCount(dashboard.plans.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
