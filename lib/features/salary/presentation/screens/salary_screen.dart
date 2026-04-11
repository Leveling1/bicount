import 'package:bicount/features/recurring_fundings/presentation/screens/recurring_salary_screen.dart';
import 'package:flutter/material.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({
    super.key,
    this.focusRecurringFundingId,
    this.focusExpectedDate,
  });

  final String? focusRecurringFundingId;
  final String? focusExpectedDate;

  @override
  Widget build(BuildContext context) {
    return RecurringSalaryScreen(
      focusRecurringFundingId: focusRecurringFundingId,
      focusExpectedDate: focusExpectedDate,
    );
  }
}
