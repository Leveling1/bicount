part of 'salary_bloc.dart';

sealed class SalaryEvent {
  const SalaryEvent();
}

final class SalaryOccurrenceConfirmRequested extends SalaryEvent {
  const SalaryOccurrenceConfirmRequested(this.occurrence);

  final SalaryOccurrenceEntity occurrence;
}

final class SalaryAutomaticModeRequested extends SalaryEvent {
  const SalaryAutomaticModeRequested(this.occurrence);

  final SalaryOccurrenceEntity occurrence;
}
