import 'package:bicount/core/constants/transaction_types.dart';

enum RecurringPlanScope { charge, income }

extension RecurringPlanScopeX on RecurringPlanScope {
  bool matchesType(int typeId) {
    return switch (this) {
      RecurringPlanScope.charge =>
        typeId == TransactionTypes.subscriptionCode ||
            typeId == TransactionTypes.otherRecurringExpenseCode,
      RecurringPlanScope.income =>
        typeId == TransactionTypes.salaryCode ||
            typeId == TransactionTypes.otherRecurringIncomeCode,
    };
  }
}
