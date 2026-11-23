import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel movement(
  String id, {
  String sender = 'owner',
  String beneficiary = 'friend',
  String? from,
  String? to,
  int type = TransactionTypes.expenseCode,
}) => TransactionModel(
  tid: id,
  uid: 'owner',
  gtid: id,
  name: id,
  type: type,
  senderId: sender,
  beneficiaryId: beneficiary,
  senderWalletId: from,
  beneficiaryWalletId: to,
  date: '2026-11-23T12:00:00',
  createdAt: '2026-11-23T12:00:00',
  note: '',
  amount: 10,
  currency: 'CDF',
);

void main() {
  final data = MainEntity(
    user: UserModel(uid: 'owner', username: '', email: '', image: ''),
    connectionState: 0,
    referenceCurrencyCode: 'CDF',
    friends: [
      FriendsModel(
        sid: 'mirror',
        uid: 'owner',
        relationType: 0,
        username: '',
        email: '',
        image: '',
      ),
    ],
    transactions: [
      movement('Bank expense', from: 'bank'),
      movement(
        'Cash income',
        sender: 'friend',
        beneficiary: 'owner',
        to: 'cash',
        type: TransactionTypes.incomeCode,
      ),
      movement('Default wallet'),
      movement('Linked alias', sender: 'mirror', from: 'bank'),
      movement(
        'Internal transfer',
        beneficiary: 'owner',
        from: 'bank',
        to: 'cash',
        type: TransactionTypes.walletTransferCode,
      ),
      movement('Counterparty wallet', from: 'cash', to: 'bank'),
    ],
    debts: const [],
    recurringTransferts: const [],
  );
  List<String> names(String? walletId, {String query = '', int type = 0}) =>
      filterTransactionFeed(
        data: data,
        source: buildTransactionFeed(data),
        walletId: walletId,
        query: query,
        selectedIndex: type,
      ).map((item) => item.transaction.name).toList();

  test(
    'wallet filter uses only current-user sides, including linked aliases',
    () {
      expect(
        names('bank'),
        unorderedEquals(['Bank expense', 'Linked alias', 'Internal transfer']),
      );
      expect(
        names('cash'),
        unorderedEquals([
          'Cash income',
          'Counterparty wallet',
          'Internal transfer',
        ]),
      );
    },
  );

  test(
    'null pointers belong to the default wallet and All wallets keeps everything',
    () {
      expect(names(WalletModel.principalId('owner')), ['Default wallet']);
      expect(names(null), hasLength(6));
      expect(names('empty'), isEmpty);
    },
  );

  test('wallet selection composes with search and type filters', () {
    expect(names('bank', query: 'linked'), ['Linked alias']);
    expect(
      names('bank', type: 2),
      unorderedEquals(['Bank expense', 'Linked alias']),
    );
    expect(names('cash', type: 1), ['Cash income']);
  });
}
