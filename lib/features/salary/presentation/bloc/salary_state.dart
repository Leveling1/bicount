part of 'salary_bloc.dart';

sealed class SalaryState {
  const SalaryState();
}

final class SalaryIdle extends SalaryState {
  const SalaryIdle();
}

final class SalaryActionInProgress extends SalaryState {
  const SalaryActionInProgress({required this.targetId});

  final String targetId;
}

final class SalaryActionSuccess extends SalaryState {
  const SalaryActionSuccess({required this.message});

  final String message;
}

final class SalaryActionFailure extends SalaryState {
  const SalaryActionFailure({required this.message});

  final String message;
}
