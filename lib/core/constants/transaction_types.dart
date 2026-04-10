import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/widgets.dart';

/// Transaction type codes aligned with the unified architecture.
///
/// `type` describes the direction of the money flow.
/// Recurrence information lives on `recurring_transfert_id` /
/// `generation_mode`, not on `type`.
class TransactionTypes {
  // ── New canonical direction-based types ──

  static const int expenseCode = 0;
  static const int incomeCode = 1;
  static const int subscriptionCode = 2;
  static const int salaryCode = 3;
  static const int otherRecurringExpenseCode = 4;
  static const int otherRecurringIncomeCode = 5;
  static const int othersCode = 6;

  // ── Legacy type aliases kept for backward migration reading ──

  /// Transaction filter chip order: [all, income, expense, subscription,
  /// salary, others].
  ///
  /// Income and expense chips are resolved from participant roles in the
  /// transaction feed. Subscription, salary, and others stay type-based.
  static const List<int> allTypesInt = [
    -1, // all
    incomeCode,
    expenseCode,
    subscriptionCode,
    salaryCode,
    othersCode,
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

  // ── UI labels ──
  static String typeLabel(BuildContext context, int typeId) {
    switch (typeId) {
      case TransactionTypes.subscriptionCode:
        return context.l10n.recurringTypeSubscription;
      case TransactionTypes.otherRecurringExpenseCode:
        return context.l10n.recurringTypeOther;
      case TransactionTypes.salaryCode:
        return context.l10n.recurringTypeSalary;
      case TransactionTypes.otherRecurringIncomeCode:
        return context.l10n.recurringTypeOtherIncome;
      default:
        return context.l10n.recurringTypeOther;
    }
  }

  // ── Expense-side type list ──
  static const List<int> expenseTypes = [
    subscriptionCode,
    otherRecurringExpenseCode,
  ];

  // ── Income-side type list ──
  static const List<int> incomeTypes = [salaryCode, otherRecurringIncomeCode];
}
