import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/analysis/data/models/analysis_contact_category.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/material.dart';
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
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();

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

  test('a custom period includes both full days and excludes nearby rows', () {
    final start = DateTime(2026, 11, 3);
    final end = DateTime(2026, 11, 5);

    TransactionModel income(String id, DateTime date, double amount) =>
        transaction(
          tid: id,
          name: id,
          type: TransactionTypes.incomeCode,
          senderId: 'friend',
          beneficiaryId: currentUserId,
          amount: amount,
          date: date,
        );

    final dashboard = builder.build(
      AnalysisSourceData(
        currentUserId: currentUserId,
        friends: const [],
        recurringTransferts: const [],
        debts: const [],
        transactions: [
          income('before', DateTime(2026, 11, 2, 23, 59), 100),
          income('start', start, 10),
          income('end', DateTime(2026, 11, 5, 23, 59), 20),
          income('after', DateTime(2026, 11, 6), 100),
        ],
      ),
      AnalysisPeriod.custom(DateTimeRange(start: start, end: end)),
      currencyConfig,
    );

    expect(dashboard.inflow, 30);
    expect(dashboard.cashflowPoints.map((point) => point.date), [
      start,
      DateTime(2026, 11, 4),
      end,
    ]);
    expect(dashboard.cashflowPoints.last.cumulativeNet, 30);
  });

  test('contact categories move ordinary flows and preserve chart totals', () {
    final friends = [
      FriendsModel(
        sid: 'alice-sid',
        fid: currentUserId,
        uid: 'alice-uid',
        username: 'Alice',
        email: '',
        image: '',
        relationType: FriendConst.friend,
      ),
      FriendsModel(
        sid: 'bob-sid',
        fid: currentUserId,
        username: 'Bob',
        email: '',
        image: '',
        relationType: FriendConst.friend,
      ),
    ];
    TransactionModel flow(
      String id,
      int type,
      String sender,
      String receiver,
      double amount,
    ) => transaction(
      tid: id,
      name: id,
      type: type,
      senderId: sender,
      beneficiaryId: receiver,
      amount: amount,
    );
    final dashboard = builder.build(
      AnalysisSourceData(
        currentUserId: currentUserId,
        friends: friends,
        recurringTransferts: const [],
        debts: const [],
        contactCategories: [
          AnalysisContactCategory.forContact(
            currentUserId,
            'alice-sid',
            AnalysisChart.income,
          ),
          AnalysisContactCategory.forContact(
            currentUserId,
            'bob-sid',
            AnalysisChart.income,
          ),
          AnalysisContactCategory.forContact(
            currentUserId,
            'bob-sid',
            AnalysisChart.expense,
          ),
        ],
        transactions: [
          flow(
            '1',
            TransactionTypes.incomeCode,
            'alice-uid',
            currentUserId,
            25,
          ),
          flow('2', TransactionTypes.incomeCode, 'alice-sid', currentUserId, 5),
          flow('3', TransactionTypes.incomeCode, 'bob-sid', currentUserId, 10),
          flow(
            '4',
            TransactionTypes.salaryCode,
            'alice-uid',
            currentUserId,
            50,
          ),
          flow(
            '5',
            TransactionTypes.expenseCode,
            currentUserId,
            'alice-sid',
            20,
          ),
          flow('6', TransactionTypes.expenseCode, currentUserId, 'bob-sid', 15),
          flow(
            '7',
            TransactionTypes.subscriptionCode,
            currentUserId,
            'bob-sid',
            12,
          ),
        ],
      ),
      AnalysisPeriod.month30,
      currencyConfig,
    );

    expect(dashboard.inflow, 90);
    expect(dashboard.outflow, 47);
    expect(dashboard.incomeBreakdown, const [
      AnalysisBreakdownItem(label: 'Salary', value: 50),
      AnalysisBreakdownItem(label: 'Alice', value: 30, friendSid: 'alice-sid'),
      AnalysisBreakdownItem(label: 'Bob', value: 10, friendSid: 'bob-sid'),
    ]);
    expect(dashboard.expenseBreakdown, const [
      AnalysisBreakdownItem(label: 'Expenses', value: 20),
      AnalysisBreakdownItem(label: 'Subscriptions', value: 12),
      AnalysisBreakdownItem(label: 'Bob', value: 15, friendSid: 'bob-sid'),
    ]);
  });

  test('migrated self-income contributes only to cashflow inflow', () {
    final dashboard = builder.build(
      AnalysisSourceData(
        currentUserId: currentUserId,
        friends: const [],
        recurringTransferts: const [],
        debts: const [],
        transactions: [
          transaction(
            tid: 'funding',
            name: 'Deposit',
            type: TransactionTypes.incomeCode,
            senderId: currentUserId,
            beneficiaryId: currentUserId,
            amount: 42,
          ),
        ],
      ),
      AnalysisPeriod.month30,
      currencyConfig,
    );

    expect(dashboard.inflow, 42);
    expect(dashboard.outflow, 0);
    expect(dashboard.cashflowPoints.last.inflow, 42);
    expect(dashboard.cashflowPoints.last.outflow, 0);
  });
}
