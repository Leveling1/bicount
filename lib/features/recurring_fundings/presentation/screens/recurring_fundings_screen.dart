import 'package:bicount/features/salary/presentation/screens/salary_screen.dart';
import 'package:flutter/material.dart';

class RecurringFundingsScreen extends StatelessWidget {
  const RecurringFundingsScreen({
    super.key,
    this.focusRecurringFundingId,
    this.focusExpectedDate,
  });

  final String? focusRecurringFundingId;
  final String? focusExpectedDate;

  @override
  Widget build(BuildContext context) {
    return SalaryScreen(
      focusRecurringFundingId: focusRecurringFundingId,
      focusExpectedDate: focusExpectedDate,
    );
  }
}
