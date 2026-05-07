part of 'debt_bloc.dart';

sealed class DebtState {
  const DebtState();
}

final class DebtIdle extends DebtState {
  const DebtIdle();
}

final class DebtActionInProgress extends DebtState {
  const DebtActionInProgress({required this.targetId});

  final String targetId;
}

final class DebtActionSuccess extends DebtState {
  const DebtActionSuccess({required this.targetId, required this.message});

  final String targetId;
  final String message;
}

final class DebtActionFailure extends DebtState {
  const DebtActionFailure({required this.message});

  final String message;
}
