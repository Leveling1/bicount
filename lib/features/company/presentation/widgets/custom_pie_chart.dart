import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart_sz/ValueSettings.dart';
import 'package:pie_chart_sz/pie_chart_sz.dart';

import '../../../../core/utils/number_format_utils.dart';

class CustomPieChart extends StatelessWidget {
  final double profit, salary, equipment, service;
  @override
  const CustomPieChart({
    super.key,
    required this.profit,
    required this.salary,
    required this.equipment,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    List<Color>? colors = [
      AppColors.incomeColorLight,
      AppColors.salaryColorDark,
      AppColors.equipmentColorDark,
      AppColors.serviceColorDark,
    ];

    List<double>? values = [profit, salary, equipment, service];

    final total = values.reduce((a, b) => a + b);

    if (total == 0) {
      return Center(
        child: Text(
          "Aucune donnée",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return PieChartSz(
      colors: colors,
      values: values,
      gapSize: 0.2,
      centerText: NumberFormatUtils.formatCurrency(profit as num),
      centerTextStyle: Theme.of(context).textTheme.headlineLarge!,
      valueSettings: Valuesettings(
        showValues: true,
        ValueTextStyle: Theme.of(context).textTheme.titleSmall!,
      ),
    );
  }
}
