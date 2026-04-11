sealed class RecurringTransfertState {
  const RecurringTransfertState();
}

class RecurringTransfertIdle extends RecurringTransfertState {
  const RecurringTransfertIdle();
}

class RecurringTransfertActionInProgress extends RecurringTransfertState {
  const RecurringTransfertActionInProgress({required this.targetId});

  final String targetId;
}

class RecurringTransfertActionSuccess extends RecurringTransfertState {
  const RecurringTransfertActionSuccess({
    required this.targetId,
    required this.message,
  });

  final String targetId;
  final String message;
}

class RecurringTransfertActionFailure extends RecurringTransfertState {
  const RecurringTransfertActionFailure({required this.message});

  final String message;
}
