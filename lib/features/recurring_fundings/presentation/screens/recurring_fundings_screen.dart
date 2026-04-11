import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/screens/recurring_salary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocProvider(
      create: (context) => RecurringTransfertBloc(
        context.read<RecurringTransfertRepositoryImpl>(),
      ),
      child: RecurringSalaryScreen(
        focusRecurringFundingId: focusRecurringFundingId,
        focusExpectedDate: focusExpectedDate,
      ),
    );
  }
}
