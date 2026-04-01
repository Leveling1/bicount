import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card_base.dart';
import 'package:flutter/material.dart';

class InfoCardAmount extends StatelessWidget {
  const InfoCardAmount({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.currencyCode,
  });

  final String icon;
  final String title;
  final double value;
  final Color color;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    return InfoCardBase(
      icon: icon,
      title: title,
      color: color,
      child: Text(
        NumberFormatUtils.formatCurrency(value, currencyCode: currencyCode),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  final String icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCardBase(
      icon: icon,
      title: title,
      color: color,
      child: Text(
        content,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class InfoCardNote extends StatelessWidget {
  const InfoCardNote({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  final String icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCardBase(
      icon: icon,
      title: title,
      color: color,
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class LinearInfoCard extends StatelessWidget {
  const LinearInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  final String icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCardBase(
      icon: icon,
      title: title,
      color: color,
      linear: true,
      child: Text(
        content,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
