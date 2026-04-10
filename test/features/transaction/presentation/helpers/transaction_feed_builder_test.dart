import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const currentUserId = 'user-1';
  const linkedSelfSid = 'friend-self';

  MainEntity buildMainEntity(List<TransactionModel> transactions) {
    return MainEntity(
      user: UserModel(
        uid: currentUserId,
        image: '',
        username: 'Me',
        email: 'me@example.com',
        referenceCurrencyCode: 'USD',
      ),
      connectionState: Constants.connected,
      referenceCurrencyCode: 'USD',
      friends: [
        FriendsModel(
          sid: linkedSelfSid,
          uid: currentUserId,
          image: '',
          username: 'My linked profile',
          email: 'me-linked@example.com',
          relationType: FriendConst.friend,
        ),
        FriendsModel(
          sid: 'friend-2',
          uid: 'friend-2-uid',
          image: '',
          username: 'Alice',
          email: 'alice@example.com',
          relationType: FriendConst.friend,
        ),
      ],
      transactions: transactions,
      recurringTransferts: const [],
    );
  }

  TransactionModel transaction({
    required String tid,
    required int type,
    required String senderId,
    required String beneficiaryId,
    required String name,
  }) {
    return TransactionModel(
      tid: tid,
      uid: currentUserId,
      gtid: 'group-$tid',
      name: name,
      type: type,
      beneficiaryId: beneficiaryId,
      senderId: senderId,
      date: DateTime(2026, 4, 10).toIso8601String(),
      note: '',
      amount: 100,
      currency: 'USD',
      createdAt: DateTime(2026, 4, 10, 12).toIso8601String(),
    );
  }

  final transactions = [
    transaction(
      tid: 'salary',
      type: TransactionTypes.salaryCode,
      senderId: 'company',
      beneficiaryId: currentUserId,
      name: 'Salary',
    ),
    transaction(
      tid: 'incoming-other',
      type: TransactionTypes.otherRecurringIncomeCode,
      senderId: 'client',
      beneficiaryId: linkedSelfSid,
      name: 'Bonus',
    ),
    transaction(
      tid: 'expense-linked',
      type: TransactionTypes.expenseCode,
      senderId: linkedSelfSid,
      beneficiaryId: 'shop',
      name: 'Groceries',
    ),
    transaction(
      tid: 'subscription',
      type: TransactionTypes.subscriptionCode,
      senderId: currentUserId,
      beneficiaryId: 'netflix',
      name: 'Netflix',
    ),
    transaction(
      tid: 'other-expense',
      type: TransactionTypes.otherRecurringExpenseCode,
      senderId: linkedSelfSid,
      beneficiaryId: 'gym',
      name: 'Gym',
    ),
    transaction(
      tid: 'others-code',
      type: TransactionTypes.othersCode,
      senderId: 'other-sender',
      beneficiaryId: currentUserId,
      name: 'Misc',
    ),
  ];

  test('income filter matches current user beneficiary identities', () {
    final data = buildMainEntity(transactions);

    final filtered = filterTransactionFeed(
      data: data,
      source: buildTransactionFeed(data),
      query: '',
      selectedIndex: 1,
    );

    expect(
      filtered.map((item) => item.id),
      containsAll(['salary', 'incoming-other', 'others-code']),
    );
    expect(filtered.map((item) => item.id), isNot(contains('expense-linked')));
  });

  test('expense filter matches current user sender identities', () {
    final data = buildMainEntity(transactions);

    final filtered = filterTransactionFeed(
      data: data,
      source: buildTransactionFeed(data),
      query: '',
      selectedIndex: 2,
    );

    expect(
      filtered.map((item) => item.id),
      containsAll(['expense-linked', 'subscription', 'other-expense']),
    );
    expect(filtered.map((item) => item.id), isNot(contains('salary')));
  });

  test('other filter only keeps recurring other income and expense types', () {
    final data = buildMainEntity(transactions);

    final filtered = filterTransactionFeed(
      data: data,
      source: buildTransactionFeed(data),
      query: '',
      selectedIndex: 5,
    );

    expect(filtered.map((item) => item.id), [
      'incoming-other',
      'other-expense',
    ]);
  });
}
