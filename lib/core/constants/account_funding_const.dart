import 'state_app.dart';

class AccountFundingType {
  static const int salary = 0;
  static const int other = 1;
}

class RecurringFundingStatus {
  static const int active = AppRecurringFundingState.active;
  static const int inactive = AppRecurringFundingState.inactive;

  static bool isActive(int? status) {
    return AppRecurringFundingState.isActive(status);
  }

  static int normalize(int? status) {
    return AppRecurringFundingState.normalize(status);
  }
}

class SalaryProcessingMode {
  static const int confirmationRequired =
      AppSalaryProcessingMode.confirmationRequired;
  static const int automatic = AppSalaryProcessingMode.automatic;

  static int normalize(int? mode) {
    return AppSalaryProcessingMode.normalize(mode);
  }

  static bool requiresConfirmation(int? mode) {
    return AppSalaryProcessingMode.requiresConfirmation(mode);
  }
}

class SalaryReminderStatus {
  static const int enabled = AppSalaryReminderState.enabled;
  static const int disabled = AppSalaryReminderState.disabled;

  static int normalize(int? status) {
    return AppSalaryReminderState.normalize(status);
  }

  static bool isEnabled(int? status) {
    return AppSalaryReminderState.isEnabled(status);
  }
}
