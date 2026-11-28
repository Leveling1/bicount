import 'dart:async';

import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_stack.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_balance_text.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const bank = WalletModel(
  id: 'bank',
  ownerUid: 'user',
  name: 'Bank',
  createdAt: '-',
);
const config = CurrencyConfigEntity(
  referenceCurrencyCode: 'CDF',
  currencies: [],
  snapshotsByKey: {
    'usd': ExchangeRateSnapshotEntity(
      currencyCode: 'USD',
      rateDate: '2026-11-23',
      rateToCdf: 2500,
    ),
  },
);

class _WalletRepository implements WalletRepository {
  List<WalletBalance> rows = [
    (walletId: 'bank', currency: 'USD', minor: 10000),
    (walletId: 'bank', currency: 'CDF', minor: 20000),
    (walletId: 'cash', currency: 'CDF', minor: -5000),
  ];
  @override
  Stream<List<WalletModel>> watch() => Stream.value([bank]);
  @override
  Future<List<WalletBalance>> balances() async => rows;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'cards show global and individual totals and refresh with money and currency changes',
    (tester) async {
      final changes = StreamController<Object?>.broadcast();
      final currency = StreamController<CurrencyConfigEntity>.broadcast();
      final repository = _WalletRepository();
      final bloc = WalletBloc(
        repository,
        currencyConfig: config,
        balanceChanges: changes.stream,
        currencyChanges: currency.stream,
      )..add(const WatchWallets());
      addTearDown(bloc.close);
      addTearDown(changes.close);
      addTearDown(currency.close);
      Future<void> pump(int index) => tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: WalletCardStack(
                  wallets: const [null, bank],
                  selectedIndex: index,
                  onChanged: (_) {},
                  balanceBuilder: (wallet) =>
                      WalletBalanceText(walletId: wallet?.id),
                ),
              ),
            ),
          ),
        ),
      );
      await pump(0);
      await tester.pumpAndSettle();
      expect(find.text('250 150 CDF'), findsOneWidget);
      await pump(1);
      await tester.pumpAndSettle();
      expect(find.text('250 200 CDF'), findsOneWidget);

      repository.rows = [(walletId: 'bank', currency: 'USD', minor: 5000)];
      changes.add(null);
      await tester.pumpAndSettle();
      expect(find.text('125 000 CDF'), findsOneWidget);
      currency.add(config.copyWith(referenceCurrencyCode: 'USD'));
      await tester.pumpAndSettle();
      expect(find.text('50 USD'), findsOneWidget);
      currency.add(config.copyWith(referenceCurrencyCode: 'CAD'));
      await tester.pumpAndSettle();
      expect(find.text('Rate unavailable for CAD'), findsOneWidget);
      currency.add(
        config.copyWith(referenceCurrencyCode: 'CAD').withSnapshotUpserts([
          const ExchangeRateSnapshotEntity(
            currencyCode: 'CAD',
            rateDate: '2026-11-23',
            rateToCdf: 2000,
          ),
        ]),
      );
      await tester.pumpAndSettle();
      expect(find.text('62.5 CAD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a long balance fits narrow cards with enlarged text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: const Center(
              child: SizedBox(
                width: 240,
                height: 150,
                child: WalletCardFace(
                  wallet: bank,
                  showDetails: true,
                  balance: Text('-123 456 789 012 CDF'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('-123 456 789 012 CDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
