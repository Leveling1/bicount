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
