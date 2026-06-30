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
) {
  final bloc = context.read<RecurringTransfertBloc>();

  return showCustomBottomSheet<void>(
    context: context,
    minHeight: 0.75,
    child: BlocProvider.value(
      value: bloc,
      child: BlocListener<RecurringTransfertBloc, RecurringTransfertState>(
        listener: (context, state) {
          if (state is RecurringTransfertActionSuccess &&
              (state.targetId == occurrence.occurrenceId ||
                  state.targetId ==
                      occurrence.recurringTransfert.recurringTransfertId)) {
            Navigator.of(context).maybePop();
          }
        },
        child: BlocBuilder<RecurringTransfertBloc, RecurringTransfertState>(
          builder: (context, state) {
            final targetId = switch (state) {
              RecurringTransfertActionInProgress(:final targetId) => targetId,
              _ => '',
            };

            return SalaryOccurrenceSheet(
              occurrence: occurrence,
              isLoading: targetId == occurrence.occurrenceId ||
                  targetId ==
                      occurrence.recurringTransfert.recurringTransfertId,
              onConfirmPressed: (confirmedAmount, confirmedCurrency) {
                context.read<RecurringTransfertBloc>().add(
                      ConfirmSalaryOccurrenceRequested(
                        occurrence: occurrence,
                        confirmedAmount: confirmedAmount,
                        confirmedCurrency: confirmedCurrency,
                      ),
                    );
              },
              onAutomaticModePressed: (confirmedAmount, confirmedCurrency) {
                context.read<RecurringTransfertBloc>().add(
                      ContinueSalaryAutomaticallyRequested(
                        occurrence: occurrence,
                        confirmedAmount: confirmedAmount,
                        confirmedCurrency: confirmedCurrency,
                      ),
                    );
              },
            );
          },
        ),
      ),
    ),
  );
}
