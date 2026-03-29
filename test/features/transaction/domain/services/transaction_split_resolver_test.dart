import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = TransactionSplitResolver();

  FriendsModel friend(String sid, String username) {
    return FriendsModel(
      sid: sid,
      uid: sid,
      username: username,
      image: '',
      email: '$username@example.com',
      relationType: FriendConst.friend,
    );
  }

  CreateTransactionRequestEntity request({
    required double totalAmount,
    required TransactionSplitMode mode,
    required List<TransactionSplitInputEntity> splits,
  }) {
    return CreateTransactionRequestEntity(
      name: 'Dinner',
      date: DateTime(2026, 3, 18).toIso8601String(),
      totalAmount: totalAmount,
      currency: 'USD',
      sender: friend('sender', 'Sender'),
      note: '',
      splitMode: mode,
      splits: splits,
    );
  }

  test('resolves an equal split and preserves the total amount', () {
    final resolved = resolver.resolve(
      request(
        totalAmount: 100,
        mode: TransactionSplitMode.equal,
        splits: [
          TransactionSplitInputEntity(beneficiary: friend('a', 'Alice')),
          TransactionSplitInputEntity(beneficiary: friend('b', 'Bob')),
          TransactionSplitInputEntity(beneficiary: friend('c', 'Charlie')),
        ],
      ),
    );

    final total = resolved.fold<double>(0, (sum, split) => sum + split.amount);
    expect(total, 100);
    expect(resolved.map((split) => split.amount), [33.34, 33.33, 33.33]);
  });

  test('resolves a percentage split and preserves the total amount', () {
    final resolved = resolver.resolve(
      request(
        totalAmount: 120,
        mode: TransactionSplitMode.percentage,
        splits: [
          TransactionSplitInputEntity(
            beneficiary: friend('a', 'Alice'),
            percentage: 50,
          ),
          TransactionSplitInputEntity(
            beneficiary: friend('b', 'Bob'),
            percentage: 30,
          ),
          TransactionSplitInputEntity(
            beneficiary: friend('c', 'Charlie'),
            percentage: 20,
          ),
        ],
      ),
    );

    expect(resolved.map((split) => split.amount).toList(), [60.0, 36.0, 24.0]);
  });

  test('throws when a custom split does not match the total', () {
    expect(
      () => resolver.resolve(
        request(
          totalAmount: 90,
          mode: TransactionSplitMode.customAmount,
          splits: [
            TransactionSplitInputEntity(
              beneficiary: friend('a', 'Alice'),
              amount: 20,
            ),
            TransactionSplitInputEntity(
              beneficiary: friend('b', 'Bob'),
              amount: 20,
            ),
          ],
        ),
      ),
      throwsA(isA<MessageFailure>()),
    );
  });
}
