import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:flutter/material.dart';

class AnalysisRecurringSummaryCard extends StatelessWidget {
  const AnalysisRecurringSummaryCard({
    super.key,
    required this.title,
    required this.description,
    required this.summary,
    required this.currencyCode,
    required this.color,
    required this.onTap,
    required this.upcomingLabel,
  });

  final String title;
  final String description;
  final AnalysisRecurringSummary summary;
  final String currencyCode;
  final Color color;
  final VoidCallback onTap;
  final String upcomingLabel;

  @override
  Widget build(BuildContext context) {
    return summary.activeCount > 0
        ? Column(
            children: [
              const SizedBox(height: AppDimens.marginMedium),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusLarge,
                  ),
                  child: DetailsCard(
                    isMargin: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: AppDimens.spacingExtraSmall,
                                  ),
                                  Text(
                                    description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimens.spacingSmall),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: color,
                              size: 18,
                            ),
                          ],
                        ),
                        AppDimens.spacerMedium,
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (summary.nextExpectedDate != null) ...[
                                Expanded(
                                  child: _MetricChip(
                                    label: upcomingLabel,
                                    value: formatDateWithoutYear(
                                      summary.nextExpectedDate!,
                                    ),
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.spacingMedium),
                              ],
                              Expanded(
                                child: _MetricChip(
                                  label: context.l10n.analysisMonthlyLoad,
                                  value: NumberFormatUtils.compactCurrency(
                                    summary.monthlyReferenceAmount,
                                    currencyCode: currencyCode,
                                    compactThreshold: 10000000,
                                  ),
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppDimens.spacerMedium,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${context.l10n.analysisActive} :',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            AppDimens.spacerWidthSmall,
                            Text(
                              '${summary.activeCount}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingSmall,
        vertical: AppDimens.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor, //color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.spacingExtraSmall),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
