import 'package:flutter/material.dart';

import '../../../../core/constants/icon_links.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/themes/other_theme.dart';
import '../../domain/entities/graph_dashboard_entity.dart';
import 'graph_metric_card.dart';

class GraphMetricOverview extends StatelessWidget {
  const GraphMetricOverview({super.key, required this.dashboard});

  final GraphDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppDimens.spacingMedium;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardWidth = availableWidth > spacing
            ? (availableWidth - spacing) / 2
            : availableWidth;

        return Wrap(
          spacing: spacing,
          //runSpacing: spacing,
          children: [
            GraphMetricCard(
              width: cardWidth,
              title: context.l10n.graphNetFlow,
              value: dashboard.netFlow,
              currencyCode: dashboard.displayCurrencyCode,
              color: dashboard.netFlow >= 0
                  ? Theme.of(context).extension<OtherTheme>()!.income!
                  : Theme.of(context).extension<OtherTheme>()!.expense!,
              icon: IconLinks.graph,
            ),
            GraphMetricCard(
              width: cardWidth,
              title: context.l10n.graphIncome,
              value: dashboard.inflow,
              currencyCode: dashboard.displayCurrencyCode,
              color: Theme.of(context).extension<OtherTheme>()!.income!,
              icon: IconLinks.income,
            ),
            GraphMetricCard(
              width: cardWidth,
              title: context.l10n.graphExpenses,
              value: dashboard.outflow,
              currencyCode: dashboard.displayCurrencyCode,
              color: Theme.of(context).extension<OtherTheme>()!.expense!,
              icon: IconLinks.expense,
            ),
          ],
        );
      },
    );
  }
}
