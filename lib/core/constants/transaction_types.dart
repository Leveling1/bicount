import 'package:bicount/core/constants/subscription_const.dart';

/// Transaction type codes aligned with the unified architecture.
///
/// `type` describes the direction of the money flow.
/// Recurrence information lives on `recurring_transfert_id` /
/// `generation_mode`, not on `type`.
class TransactionTypes {
  // ── New canonical direction-based types ──

  static const int expenseCode = 0;
  static const int incomeCode = 1;

  // ── Legacy type aliases kept for backward migration reading ──

  static const transfer = 0;
  static const subscription = 1;
  static const addFund = 2;
  static const int othersCode = 3;
  @Deprecated('Use expenseCode or incomeCode instead')
  static const int subscriptionCode = 4;

  static const String transferText = 'Transfer';
  static const String subscriptionText = 'Subscription';
  static const String addFundText = 'Add a fund';

  static const personal = 99;

  /// Filter list: [all, income, expense, personal]
  static const List<int> allTypesInt = [
    -1, // all
    incomeCode,
    expenseCode,
    personal,
  ];

  // ── Generation mode on transactions ──

  static const int generationOneTime = 0;
  static const int generationManualConfirmation = 1;
  static const int generationBackendAutomatic = 2;

  static String frequencyToString(int frequency) {
    switch (frequency) {
      case Frequency.oneTime:
        return Frequency.oneTimeString;
      case Frequency.weekly:
        return Frequency.weeklyString;
      case Frequency.monthly:
        return Frequency.monthlyString;
      case Frequency.quarterly:
        return Frequency.quarterlyString;
      case Frequency.yearly:
        return Frequency.yearlyString;
      default:
        return Frequency.oneTimeString;
    }
  }
}
