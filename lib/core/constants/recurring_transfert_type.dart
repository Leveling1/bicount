import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Centralized reference for all recurring transfert types.
///
/// Each entry mirrors the `recurring_transfert_type` backend table.
/// IDs are stable smallint foreign keys starting at 0.
final class RecurringTransfertType {
  const RecurringTransfertType._();

  // ── IDs (match backend `recurring_transfert_type.id`) ──

  static const int subscriptionExpense = 0;
  static const int recurringExpenseOther = 1;
  static const int salaryIncome = 2;
  static const int recurringIncomeOther = 3;

  // ── Direction helpers ──

  static const int directionExpense = 0;
  static const int directionIncome = 1;

  static int direction(int typeId) {
    switch (typeId) {
      case subscriptionExpense:
      case recurringExpenseOther:
        return directionExpense;
      case salaryIncome:
      case recurringIncomeOther:
        return directionIncome;
      default:
        return directionExpense;
    }
  }

  static bool isExpense(int typeId) => direction(typeId) == directionExpense;
  static bool isIncome(int typeId) => direction(typeId) == directionIncome;

  // ── Seed data codes (mirror backend `code` column) ──

  static const String codeSubscriptionExpense = 'subscription_expense';
  static const String codeRecurringExpenseOther = 'recurring_expense_other';
  static const String codeSalaryIncome = 'salary_income';
  static const String codeRecurringIncomeOther = 'recurring_income_other';

  static String code(int typeId) {
    switch (typeId) {
      case subscriptionExpense:
        return codeSubscriptionExpense;
      case recurringExpenseOther:
        return codeRecurringExpenseOther;
      case salaryIncome:
        return codeSalaryIncome;
      case recurringIncomeOther:
        return codeRecurringIncomeOther;
      default:
        return codeSubscriptionExpense;
    }
  }

  // ── Expense-side type list ──

  static const List<int> expenseTypes = [
    subscriptionExpense,
    recurringExpenseOther,
  ];

  // ── Income-side type list ──

  static const List<int> incomeTypes = [salaryIncome, recurringIncomeOther];


  // ── UI labels ──
  static String typeLabel(BuildContext context, int typeId) {
    switch (typeId) {
      case RecurringTransfertType.subscriptionExpense:
        return context.l10n.recurringTypeSubscription;
      case RecurringTransfertType.recurringExpenseOther:
        return context.l10n.recurringTypeOther;
      case RecurringTransfertType.salaryIncome:
        return context.l10n.recurringTypeSalary;
      case RecurringTransfertType.recurringIncomeOther:
        return context.l10n.recurringTypeOtherIncome;
      default:
        return context.l10n.recurringTypeOther;
    }
  }
}
