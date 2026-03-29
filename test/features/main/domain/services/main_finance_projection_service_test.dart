import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/services/main_finance_projection_service.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = MainFinanceProjectionService();

  final user = UserModel(
    uid: 'user-1',
    image: '',
    username: 'Louis',
    email: 'louis@example.com',
    balance: 999,
    incomes: 999,
    expenses: 999,
    personalIncome: 999,
    companyIncome: 999,
  );

  test('projects user totals from raw transactions and fundings', () {
    final result = service.project(
      user: user,
      friends: const [],
      subscriptions: const [],
      transactions: [
        TransactionModel(
          uid: 'user-1',
          gtid: 'gtid-1',
          name: 'Expense',
          type: 0,
          beneficiaryId: 'friend-a',
          senderId: 'user-1',
          date: '2026-03-23',
          note: '',
          amount: 50,
          currency: 'USD',
          category: Constants.personal,
        ),
        TransactionModel(
          uid: 'user-1',
          gtid: 'gtid-2',
          name: 'Income',
          type: 1,
          beneficiaryId: 'user-1',
          senderId: 'friend-a',
          date: '2026-03-23',
          note: '',
          amount: 20,
          currency: 'USD',
          category: Constants.company,
        ),
      ],
      accountFundings: [
        AccountFundingModel(
          sid: 'user-1',
          amount: 30,
          currency: 'USD',
          category: Constants.personal,
          source: 'cash',
          date: '2026-03-23',
        ),
      ],
      connectionState: Constants.connected,
      currencyConfig: CurrencyConfigEntity.fallback(),
    );

    expect(result.user.balance, 0);
    expect(result.user.incomes, 50);
    expect(result.user.expenses, 50);
    expect(result.user.personalIncome, -20);
    expect(result.user.companyIncome, 20);
  });

  test('projects friend totals using sid and linked uid aliases', () {
    final result = service.project(
      user: user,
      friends: [
        FriendsModel(
          sid: 'friend-local',
          uid: 'friend-real',
          fid: 'user-1',
          image: '',
          username: 'Alice',
          email: 'alice@example.com',
          relationType: FriendConst.friend,
          give: 99,
          receive: 88,
          personalIncome: 77,
          companyIncome: 66,
        ),
      ],
      subscriptions: const [],
      transactions: [
        TransactionModel(
          uid: 'user-1',
          gtid: 'gtid-1',
          name: 'From alias',
          type: 0,
          beneficiaryId: 'user-1',
          senderId: 'friend-real',
          date: '2026-03-23',
          note: '',
          amount: 12,
          currency: 'USD',
          category: Constants.personal,
        ),
        TransactionModel(
          uid: 'user-1',
          gtid: 'gtid-2',
          name: 'To sid',
          type: 0,
          beneficiaryId: 'friend-local',
          senderId: 'user-1',
          date: '2026-03-23',
          note: '',
          amount: 7,
          currency: 'USD',
          category: Constants.company,
        ),
      ],
      accountFundings: const [],
      connectionState: Constants.connected,
      currencyConfig: CurrencyConfigEntity.fallback(),
    );

    final friend = result.friends.single;
    expect(friend.give, 12);
    expect(friend.receive, 7);
    expect(friend.personalIncome, -12);
    expect(friend.companyIncome, 7);
  });
}
