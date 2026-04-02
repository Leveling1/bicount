import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/home_salary_status_card.dart';
import 'package:flutter/material.dart';

class HomeRecurringFundingsStatusCard extends StatelessWidget {
  const HomeRecurringFundingsStatusCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final MainEntity data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSalaryStatusCard(data: data, onTap: onTap);
  }
}
