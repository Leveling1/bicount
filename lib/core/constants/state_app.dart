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
