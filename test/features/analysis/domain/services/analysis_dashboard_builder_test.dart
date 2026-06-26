import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
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
    String? originId,
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
      originId: originId,
    );
  }

  DebtModel debt({
    required String debtId,
    required String principalTransactionId,
    required String lenderId,
    required String borrowerId,
  }) {
    final now = DateTime.now().toIso8601String();

    return DebtModel(
      debtId: debtId,
      createdBy: currentUserId,
      lenderId: lenderId,
      borrowerId: borrowerId,
      principalTransactionId: principalTransactionId,
      title: 'Debt',
      currency: 'CDF',
      principalAmount: 100,
      expectedRepaymentAmount: 100,
      remainingAmount: 100,
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'analysis dashboard classifies linked self-profile flows like the feed',
    () {
      const lentDebtId = 'debt-lent';
      const borrowedDebtId = 'debt-borrowed';
      final dashboard = builder.build(
        AnalysisSourceData(
          currentUserId: currentUserId,
          friends: [linkedSelfProfile()],
          recurringTransferts: const [],
          debts: [
            debt(
              debtId: lentDebtId,
              principalTransactionId: 'debt-principal-expense',
              lenderId: currentUserId,
              borrowerId: 'friend',
            ),
            debt(
              debtId: borrowedDebtId,
              principalTransactionId: 'debt-principal-income',
              lenderId: 'lender',
              borrowerId: currentUserId,
            ),
          ],
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
              tid: 'debt-principal-income',
              name: 'Borrowed money',
              type: TransactionTypes.debtCode,
              senderId: 'lender',
              beneficiaryId: linkedSelfSid,
              amount: 50,
              originId: borrowedDebtId,
            ),
            transaction(
              tid: 'debt-repayment-income',
              name: 'Debt repayment',
              type: TransactionTypes.debtCode,
              senderId: 'friend',
              beneficiaryId: currentUserId,
              amount: 60,
              originId: lentDebtId,
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
              tid: 'debt-principal-expense',
              name: 'Money lent',
              type: TransactionTypes.debtCode,
              senderId: currentUserId,
              beneficiaryId: 'friend',
              amount: 100,
              originId: lentDebtId,
            ),
            transaction(
              tid: 'debt-repayment-expense',
              name: 'Debt repayment sent',
              type: TransactionTypes.debtCode,
              senderId: currentUserId,
              beneficiaryId: 'lender',
              amount: 70,
              originId: borrowedDebtId,
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

      expect(dashboard.inflow, 1210);
      expect(dashboard.outflow, 295);
      expect(dashboard.netFlow, 915);
      expect(dashboard.incomeBreakdown, const [
        AnalysisBreakdownItem(label: 'Income', value: 35),
        AnalysisBreakdownItem(label: 'Salary', value: 1000),
        AnalysisBreakdownItem(label: 'Debt', value: 50),
        AnalysisBreakdownItem(label: 'Repayments', value: 60),
        AnalysisBreakdownItem(label: 'Other', value: 65),
      ]);
      expect(dashboard.expenseBreakdown, const [
        AnalysisBreakdownItem(label: 'Expenses', value: 30),
        AnalysisBreakdownItem(label: 'Subscriptions', value: 20),
        AnalysisBreakdownItem(label: 'Debt', value: 100),
        AnalysisBreakdownItem(label: 'Repayments', value: 70),
        AnalysisBreakdownItem(label: 'Other', value: 75),
      ]);

      final latestPoint = dashboard.cashflowPoints.last;
      expect(latestPoint.inflow, 1210);
      expect(latestPoint.outflow, 295);
      expect(latestPoint.cumulativeNet, 915);
    },
  );
}
