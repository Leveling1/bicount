import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/presentation/bloc/graph_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      builder: (context, state) {
        if (state.status == GraphStatus.loading && state.dashboard == null) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Theme.of(context).primaryColor,
              size: 36,
            ),
          );
        }

        if (state.status == GraphStatus.failure && state.dashboard == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Text(
                state.errorMessage ?? 'Unable to load analytics',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final dashboard = state.dashboard;
        if (dashboard == null) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SingleChildScrollView(
            key: ValueKey(state.period),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingMedium,
              AppDimens.paddingLarge,
              AppDimens.paddingMedium,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.marginSmall),
                Text(
                  'Track your flow, spot your recurring costs and keep the useful signals close.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimens.marginLarge),
                _PeriodSelector(
                  selectedPeriod: state.period,
                  onSelected: (period) {
                    context.read<GraphBloc>().add(GraphPeriodChanged(period));
                  },
                ),
                const SizedBox(height: AppDimens.marginLarge),
                Wrap(
                  spacing: AppDimens.spacingMedium,
                  runSpacing: AppDimens.spacingMedium,
                  children: [
                    _MetricCard(
                      width: 165.w,
                      title: 'Net flow',
                      value: dashboard.netFlow,
                      color: dashboard.netFlow >= 0
                          ? Theme.of(context).extension<OtherTheme>()!.income!
                          : Theme.of(context).extension<OtherTheme>()!.expense!,
                      icon: IconLinks.graph,
                    ),
                    _MetricCard(
                      width: 165.w,
                      title: 'Income',
                      value: dashboard.inflow,
                      color: Theme.of(context).extension<OtherTheme>()!.income!,
                      icon: IconLinks.income,
                    ),
                    _MetricCard(
                      width: 165.w,
                      title: 'Expenses',
                      value: dashboard.outflow,
                      color: Theme.of(
                        context,
                      ).extension<OtherTheme>()!.expense!,
                      icon: IconLinks.expense,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Cashflow trend',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _CashflowChart(dashboard: dashboard),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Expense mix',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _ExpenseBreakdownCard(dashboard: dashboard),
                const SizedBox(height: AppDimens.marginLarge),
                Text(
                  'Subscriptions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _SubscriptionInsightCard(dashboard: dashboard),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onSelected,
  });

  final GraphPeriod selectedPeriod;
  final ValueChanged<GraphPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: GraphPeriod.values.map((period) {
          final selected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.label),
              selected: selected,
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.16),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              onSelected: (_) => onSelected(period),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final double width;
  final String title;
  final double value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DetailsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.14),
              child: SvgPicture.asset(
                icon,
                width: AppDimens.iconSizeSmall,
                height: AppDimens.iconSizeSmall,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: AppDimens.marginMedium),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return Text(
                  NumberFormatUtils.formatCurrency(animatedValue),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CashflowChart extends StatelessWidget {
  const _CashflowChart({required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    if (dashboard.cashflowPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final lineColor = Theme.of(context).primaryColor;
    final minValue = dashboard.cashflowPoints
        .map((point) => point.cumulativeNet)
        .reduce((left, right) => left < right ? left : right);
    final maxValue = dashboard.cashflowPoints
        .map((point) => point.cumulativeNet)
        .reduce((left, right) => left > right ? left : right);

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cumulative net',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                dashboard.period.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.marginLarge),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minValue > 0 ? 0 : minValue * 1.15,
                maxY: maxValue <= 0 ? 0 : maxValue * 1.15,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: ((maxValue - minValue).abs() / 4).clamp(
                    20,
                    5000,
                  ),
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.18),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            NumberFormatUtils.compactCurrency(value),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _bottomInterval(
                        dashboard.cashflowPoints.length,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= dashboard.cashflowPoints.length) {
                          return const SizedBox.shrink();
                        }
                        final point = dashboard.cashflowPoints[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dashboard.period == GraphPeriod.all
                                ? DateFormat('MMM yy').format(point.date)
                                : DateFormat('dd MMM').format(point.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dashboard.cashflowPoints.asMap().entries.map((
                      entry,
                    ) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.cumulativeNet,
                      );
                    }).toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _bottomInterval(int length) {
    if (length <= 7) {
      return 1;
    }
    if (length <= 15) {
      return 3;
    }
    if (length <= 35) {
      return 6;
    }
    final interval = (length / 5).floorToDouble();
    return interval < 1 ? 1 : interval;
  }
}

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).extension<OtherTheme>()!.expense!,
      AppColors.quaternaryColorBasic,
      Colors.orange,
    ];

    return DetailsCard(
      child: dashboard.expenseBreakdown.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingLarge,
              ),
              child: Center(
                child: Text(
                  'No outgoing transactions for this period yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 52,
                      sectionsSpace: 2,
                      sections: dashboard.expenseBreakdown.asMap().entries.map((
                        entry,
                      ) {
                        final color = colors[entry.key % colors.length];
                        final total = dashboard.expenseBreakdown.fold<double>(
                          0,
                          (sum, item) => sum + item.value,
                        );
                        final percent = total == 0
                            ? 0.0
                            : (entry.value.value / total) * 100;
                        return PieChartSectionData(
                          value: entry.value.value,
                          color: color,
                          radius: 42,
                          title: '${percent.toStringAsFixed(0)}%',
                          titleStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.marginMedium),
                ...dashboard.expenseBreakdown.asMap().entries.map((entry) {
                  final color = colors[entry.key % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value.label,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          NumberFormatUtils.formatCurrency(entry.value.value),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _SubscriptionInsightCard extends StatelessWidget {
  const _SubscriptionInsightCard({required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              _SubscriptionStat(
                title: 'Active',
                value: '${dashboard.activeSubscriptionCount}',
              ),
              _SubscriptionStat(
                title: 'Monthly load',
                value: NumberFormatUtils.formatCurrency(
                  dashboard.monthlySubscriptionSpend,
                ),
              ),
              _SubscriptionStat(
                title: 'Next 7 days',
                value: NumberFormatUtils.formatCurrency(
                  dashboard.dueSoonAmount,
                ),
              ),
            ],
          ),
          if (dashboard.upcomingSubscriptions.isNotEmpty) ...[
            const SizedBox(height: AppDimens.marginLarge),
            Text(
              'Upcoming charges',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimens.marginMedium),
            ...dashboard.upcomingSubscriptions.map((subscription) {
              final nextBillingDate = DateFormat(
                'dd MMM yyyy',
              ).format(subscription.nextBillingDate);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.14),
                      child: Icon(
                        Icons.subscriptions_outlined,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${Frequency.getFrequencyString(subscription.frequency)} • $nextBillingDate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormatUtils.formatCurrency(subscription.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: AppDimens.marginLarge),
            Text(
              'No active subscriptions scheduled yet.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionStat extends StatelessWidget {
  const _SubscriptionStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
