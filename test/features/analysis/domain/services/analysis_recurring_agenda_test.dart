import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'projects active plans through their last day and keeps both scopes',
    () {
      RecurringTransfertModel plan(
        String title,
        int type,
        int frequency,
        String start, {
        String? end,
        int status = AppRecurringTransfertState.active,
      }) => RecurringTransfertModel(
        uid: 'user',
        recurringTransfertTypeId: type,
        title: title,
        amount: 20,
        currency: 'CDF',
        senderId: '',
        beneficiaryId: '',
        frequency: frequency,
        startDate: start,
        nextDueDate: start,
        endDate: end,
        status: status,
      );

      final days = const AnalysisRecurringAgenda()
          .forMonth(DateTime(2026, 11), [
            plan(
              'Weekly',
              TransactionTypes.subscriptionCode,
              Frequency.weekly,
              '2026-10-30',
              end: '2026-11-13',
            ),
            plan(
              'Salary',
              TransactionTypes.salaryCode,
              Frequency.monthly,
              '2026-10-06',
            ),
            plan(
              'Legacy quarter',
              TransactionTypes.otherRecurringIncomeCode,
              4,
              '2026-08-20',
            ),
            plan(
              'Archived',
              TransactionTypes.subscriptionCode,
              Frequency.monthly,
              '2026-11-14',
              status: AppRecurringTransfertState.archived,
            ),
            plan(
              'Unknown schedule',
              TransactionTypes.subscriptionCode,
              999,
              '2026-10-01',
            ),
          ]);

      expect(
        days.keys,
        unorderedEquals([
          DateTime(2026, 11, 6),
          DateTime(2026, 11, 13),
          DateTime(2026, 11, 20),
        ]),
      );
      expect(days[DateTime(2026, 11, 6)]!.map((entry) => entry.scope), [
        RecurringPlanScope.income,
        RecurringPlanScope.charge,
      ]);
      expect(days[DateTime(2026, 11, 13)]!.single.plan.title, 'Weekly');
      expect(days[DateTime(2026, 11, 20)]!.single.plan.title, 'Legacy quarter');
    },
  );
}
