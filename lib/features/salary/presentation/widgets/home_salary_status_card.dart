import 'package:bicount/core/animations/bicount_pressable.dart';
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
      recurringTransferts: data.recurringTransferts,
      transactions: data.transactions,
      currencyConfig: currencyConfig,
    );
    if (!dashboard.hasPlans) {
      return const SizedBox.shrink();
    }

    final accentColor = dashboard.hasAttention
        ? Theme.of(context).extension<OtherTheme>()!.expense!
        : Theme.of(context).textTheme.bodySmall?.color;
    final expectedDate = dashboard.hasAttention
        ? dashboard.attentionOccurrences.first.expectedDate
        : dashboard.nextExpectedDate;

    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: BicountPressable(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          customBorder: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          ),
          onTap: onTap,
          child: Padding(
            padding: AppDimens.paddingSmallCard,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: AppSizes.dp20,
                  child: SizedBox(
                    width: AppSizes.dp30,
                    height: AppSizes.dp30,
                    child: Icon(
                      Icons.arrow_forward_outlined,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                AppDimens.spacerWidthMediumSmall,

                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.salaryHomeCardTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        expectedDate == null
                            ? '-'
                            : formatDateWithoutYear(expectedDate),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: AppSizes.dp13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dashboard.hasAttention
                          ? NumberFormatUtils.compactCurrency(
                              dashboard.totalOutstandingAmount,
                              currencyCode: data.referenceCurrencyCode,
                            )
                          : dashboard.nextExpectedDate == null
                          ? '-'
                          : formatDateWithoutYear(dashboard.nextExpectedDate!),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.dp16,
                      ),
                    ),
                    Text(
                      dashboard.hasAttention
                          ? context.l10n.salaryHomeCardAttention
                          : context.l10n.salaryHomeCardNext,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
