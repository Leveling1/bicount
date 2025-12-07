import 'package:flutter/material.dart';

class SubscriptionConst {
  static const int active = 0;
  static const int paused = 1;
  static const int unsubscribed = 2;

  static const String activeString = "Active";
  static const String pausedString = "Paused";
  static const String unsubscribedString = "Unsubscribed";

  static String getStatusString(int status) {
    switch (status) {
      case active:
        return activeString;
      case paused:
        return pausedString;
      case unsubscribed:
        return unsubscribedString;
      default:
        return "";
    }
  }

  static Color getStatusColor(int status, BuildContext context) {
    switch (status) {
      case active:
        return Theme.of(context).primaryColor;
      case paused:
        return Colors.orange;
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
