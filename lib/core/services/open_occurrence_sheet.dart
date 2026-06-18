import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_state.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_occurrence_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> openOccurrenceSheet(
    BuildContext context,
    SalaryOccurrenceEntity occurrence,
    RecurringTransfertState recurringState,
  ) {
    final targetId = switch (recurringState) {
      RecurringTransfertActionInProgress(:final targetId) => targetId,
      _ => '',
    };

    return showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.75,
      child: SalaryOccurrenceSheet(
        occurrence: occurrence,
        isLoading:
            targetId == occurrence.occurrenceId ||
            targetId == occurrence.recurringTransfert.recurringTransfertId,
        onConfirmPressed: (confirmedAmount, confirmedCurrency) {
          Navigator.of(context).maybePop();
          context.read<RecurringTransfertBloc>().add(
            ConfirmSalaryOccurrenceRequested(
              occurrence: occurrence,
              confirmedAmount: confirmedAmount,
              confirmedCurrency: confirmedCurrency,
            ),
          );
        },
        onAutomaticModePressed: (confirmedAmount, confirmedCurrency) {
          Navigator.of(context).maybePop();
          context.read<RecurringTransfertBloc>().add(
            ContinueSalaryAutomaticallyRequested(
              occurrence: occurrence,
              confirmedAmount: confirmedAmount,
              confirmedCurrency: confirmedCurrency,
            ),
          );
        },
      ),
    );
  }