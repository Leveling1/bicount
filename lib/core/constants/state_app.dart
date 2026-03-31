final class AppSubscriptionState {
  const AppSubscriptionState._();

  static const int subscribed = 0;
  static const int unsubscribed = 1;

  static int normalize(int? status) {
    return status == subscribed ? subscribed : unsubscribed;
  }

  static bool isSubscribed(int? status) {
    return normalize(status) == subscribed;
  }
}

final class AppRecurringFundingState {
  const AppRecurringFundingState._();

  static const int active = 0;
  static const int inactive = 1;

  static int normalize(int? status) {
    return status == active ? active : inactive;
  }

  static bool isActive(int? status) {
    return normalize(status) == active;
  }
}

final class AppSalaryProcessingMode {
  const AppSalaryProcessingMode._();

  static const int confirmationRequired = 0;
  static const int automatic = 1;

  static int normalize(int? mode) {
    return mode == confirmationRequired ? confirmationRequired : automatic;
  }

  static bool requiresConfirmation(int? mode) {
    return normalize(mode) == confirmationRequired;
  }

  static bool isAutomatic(int? mode) {
    return normalize(mode) == automatic;
  }
}

final class AppSalaryReminderState {
  const AppSalaryReminderState._();

  static const int enabled = 0;
  static const int disabled = 1;

  static int normalize(int? status) {
    return status == disabled ? disabled : enabled;
  }

  static bool isEnabled(int? status) {
    return normalize(status) == enabled;
  }
}

final class AppSalaryOccurrenceState {
  const AppSalaryOccurrenceState._();

  static const int upcoming = 0;
  static const int dueToday = 1;
  static const int overdue = 2;
  static const int received = 3;

  static int normalize(int? status) {
    switch (status) {
      case dueToday:
        return dueToday;
      case overdue:
        return overdue;
      case received:
        return received;
      case upcoming:
      default:
        return upcoming;
    }
  }

  static bool needsAttention(int? status) {
    final normalized = normalize(status);
    return normalized == dueToday || normalized == overdue;
  }
}
