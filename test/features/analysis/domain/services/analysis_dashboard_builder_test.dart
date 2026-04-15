import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const currentUserId = 'me';
  const linkedSelfSid = 'me-linked';
  const builder = AnalysisDashboardBuilder();
  const currencyConfig = CurrencyConfigEntity(
    referenceCurrencyCode: 'CDF',
    currencies: [],
    snapshotsByKey: {},
  );

  FriendsModel linkedSelfProfile() {
    return FriendsModel(
      sid: linkedSelfSid,
      uid: currentUserId,
      image: '',
      username: 'Me linked',
      email: 'me@example.com',
      relationType: FriendConst.friend,
    );
  }

  TransactionModel transaction({
    required String tid,
    required String name,
    required int type,
    required String senderId,
    required String beneficiaryId,
    required double amount,
  }) {
    final now = DateTime.now();

    return TransactionModel(
      tid: tid,
      uid: currentUserId,
      gtid: 'group-$tid',
      name: name,
      type: type,
      beneficiaryId: beneficiaryId,
      senderId: senderId,
      date: now.toIso8601String(),
      note: '',
      amount: amount,
      currency: 'CDF',
      createdAt: now.toIso8601String(),
    );
  }

  test(
    'analysis dashboard classifies linked self-profile flows like the feed',
    () {
      final dashboard = builder.build(
        AnalysisSourceData(
          currentUserId: currentUserId,
          friends: [linkedSelfProfile()],
          recurringTransferts: const [],
          transactions: [
            transaction(
              tid: 'salary',
              name: 'Salary',
              type: TransactionTypes.salaryCode,
              senderId: 'company',
              beneficiaryId: currentUserId,
              amount: 1000,
            ),
            transaction(
              tid: 'income',
              name: 'Cash',
              type: TransactionTypes.incomeCode,
              senderId: 'client',
              beneficiaryId: currentUserId,
              amount: 35,
            ),
            transaction(
              tid: 'legacy-linked-income',
              name: 'Legacy linked income',
              type: TransactionTypes.othersCode,
              senderId: 'payer',
              beneficiaryId: linkedSelfSid,
              amount: 40,
            ),
            transaction(
              tid: 'other-income',
              name: 'Other income',
              type: TransactionTypes.otherRecurringIncomeCode,
              senderId: 'side-hustle',
              beneficiaryId: linkedSelfSid,
              amount: 25,
            ),
            transaction(
              tid: 'expense',
              name: 'Groceries',
              type: TransactionTypes.expenseCode,
              senderId: currentUserId,
              beneficiaryId: 'shop',
              amount: 30,
            ),
            transaction(
              tid: 'legacy-linked-expense',
              name: 'Legacy linked expense',
              type: TransactionTypes.othersCode,
              senderId: linkedSelfSid,
              beneficiaryId: 'friend',
              amount: 60,
            ),
            transaction(
              tid: 'subscription',
              name: 'Subscription',
              type: TransactionTypes.subscriptionCode,
              senderId: currentUserId,
              beneficiaryId: 'netflix',
              amount: 20,
            ),
            transaction(
              tid: 'other-expense',
              name: 'Other expense',
              type: TransactionTypes.otherRecurringExpenseCode,
              senderId: linkedSelfSid,
              beneficiaryId: 'gym',
              amount: 15,
            ),
          ],
        ),
        AnalysisPeriod.month30,
        currencyConfig,
      );

      expect(dashboard.inflow, 1100);
      expect(dashboard.outflow, 125);
      expect(dashboard.netFlow, 975);
      expect(dashboard.incomeBreakdown, const [
        AnalysisBreakdownItem(label: 'Income', value: 75),
        AnalysisBreakdownItem(label: 'Salary', value: 1000),
        AnalysisBreakdownItem(label: 'Other', value: 25),
      ]);
      expect(dashboard.expenseBreakdown, const [
        AnalysisBreakdownItem(label: 'Expenses', value: 90),
        AnalysisBreakdownItem(label: 'Subscriptions', value: 20),
        AnalysisBreakdownItem(label: 'Other', value: 15),
      ]);

      final latestPoint = dashboard.cashflowPoints.last;
      expect(latestPoint.inflow, 1100);
      expect(latestPoint.outflow, 125);
      expect(latestPoint.cumulativeNet, 975);
    },
  );
}
