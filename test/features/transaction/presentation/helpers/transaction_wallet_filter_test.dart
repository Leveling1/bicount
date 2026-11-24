import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_direction_service.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel movement(
  String id, {
  String sender = 'owner',
  String beneficiary = 'friend',
  String? from,
  String? to,
  String? name,
  int type = TransactionTypes.expenseCode,
}) => TransactionModel(
  tid: id,
  uid: 'owner',
  gtid: id,
  name: name ?? id,
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
        name: 'Transfer between wallets',
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
      ).map((item) => item.id).toList();

  test('wallet filter uses current-user sides and aliases', () {
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
  });

  test('null pointers use the principal wallet', () {
    expect(names(WalletModel.principalId('owner')), ['Default wallet']);
    expect(names(null), hasLength(6));
    expect(names('empty'), isEmpty);
  });

  test('wallet selection composes with search and type filters', () {
    expect(names('bank', query: 'linked'), ['Linked alias']);
    expect(
      names('bank', type: 2),
      unorderedEquals(['Bank expense', 'Linked alias', 'Internal transfer']),
    );
    expect(
      names('cash', type: 1),
      unorderedEquals(['Cash income', 'Internal transfer']),
    );
    expect(names('bank', type: 1), isEmpty);
    expect(names('cash', type: 2), ['Counterparty wallet']);
  });

  test('a transfer has a sign only for the selected wallet', () {
    for (final (walletId, sign) in [
      ('bank', TransactionSign.negative),
      ('cash', TransactionSign.positive),
      (null, TransactionSign.none),
    ]) {
      final transfer = filterTransactionFeed(
        data: data,
        source: buildTransactionFeed(data),
        walletId: walletId,
        query: 'transfer',
        selectedIndex: 0,
      ).single;
      expect(transfer.walletTransferDirection?.sign, sign);
      expect(transfer.transaction.type, TransactionTypes.walletTransferCode);
    }
    for (final index in [1, 2, 3, 4, 5, 6]) {
      expect(names(null, query: 'transfer', type: index), isEmpty);
    }
  });

  testWidgets('legacy titles use both wallet labels and are searchable', (
    tester,
  ) async {
    const from = WalletModel(
      id: 'bank',
      ownerUid: 'owner',
      name: 'Visa',
      createdAt: '',
    );
    const to = WalletModel(
      id: 'cash',
      ownerUid: 'owner',
      name: 'Orange Money',
      createdAt: '',
      archivedAt: '2026-11-24',
    );
    Future<void> pumpLocalized(Widget body) => tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: body),
      ),
    );
    await pumpLocalized(const SizedBox(key: ValueKey('feed context')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const ValueKey('feed context')));
    final transfer = filterTransactionFeed(
      data: data,
      source: buildTransactionFeed(data, context: context, wallets: [from, to]),
      walletId: 'cash',
      query: 'orange money',
      selectedIndex: 1,
    ).single;
    expect(transfer.displayTitle, 'Transfert de Visa vers Orange Money');
    expect(transfer.transaction.name, 'Transfer between wallets');

    final fallback = buildTransactionFeed(
      data,
      context: context,
      wallets: [from],
    ).singleWhere((item) => item.id == transfer.id);
    expect(fallback.displayTitle, 'Transfert interne');

    await pumpLocalized(
      TransactionCard(
        transaction: transfer.transaction,
        displayTitle: transfer.displayTitle,
        walletTransferDirection: transfer.walletTransferDirection,
      ),
    );
    final amount = NumberFormatUtils.formatCurrency(10, currencyCode: 'CDF');
    expect(find.text('Transfert de Visa vers Orange Money'), findsOneWidget);
    expect(find.text('Transfert interne'), findsOneWidget);
    expect(find.text('+ $amount'), findsOneWidget);
  });
}
