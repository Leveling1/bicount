import 'package:flutter/material.dart';

import 'state_app.dart';

class SubscriptionConst {
  static const int active = AppSubscriptionState.subscribed;
  static const int unsubscribed = AppSubscriptionState.unsubscribed;

  static bool isActive(int? status) {
    return AppSubscriptionState.isSubscribed(status);
  }

  static int normalize(int? status) {
    return AppSubscriptionState.normalize(status);
  }

  static Color getStatusColor(int status, BuildContext context) {
    switch (normalize(status)) {
      case active:
        return Theme.of(context).primaryColor;
      case unsubscribed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Frequency {
  static const int weekly = 0;
  static const int monthly = 1;
  static const int quarterly = 2;
  static const int yearly = 3;
  static const int oneTime = 4;

  static const String weeklyString = "Weekly";
  static const String monthlyString = "Monthly";
  static const String quarterlyString = "Quarterly";
  static const String yearlyString = "Yearly";
  static const String oneTimeString = "One Time";

  static String getFrequencyString(int frequency) {
    switch (frequency) {
      case weekly:
        return weeklyString;
      case monthly:
        return monthlyString;
      case quarterly:
        return quarterlyString;
      case yearly:
        return yearlyString;
      case oneTime:
        return oneTimeString;
      default:
        return "";
    }
  }
}
