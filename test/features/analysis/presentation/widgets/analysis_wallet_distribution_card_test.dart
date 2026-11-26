import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_wallet_distribution_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_wallet_distribution_ring.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'plots comparable positive balances and updates after a transfer',
    (tester) async {
      final repository = _WalletRepository();
      final allWallets = repository.wallets;
      repository.wallets = allWallets.take(1).toList();
      final bloc = WalletBloc(
        repository,
        currencyConfig: const CurrencyConfigEntity(
          referenceCurrencyCode: 'CDF',
          currencies: [],
          snapshotsByKey: {
            'usd': ExchangeRateSnapshotEntity(
              currencyCode: 'USD',
              rateDate: '2026-11-26',
              rateToCdf: 2500,
            ),
          },
        ),
      )..add(const WatchWallets());
      addTearDown(bloc.close);
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AnalysisWalletDistributionCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(AnalysisWalletDistributionCard);
      final title = find.text('Wallet distribution');
      expect(title, findsNothing);
      expect(tester.getSize(card).height, 0);

      repository.wallets = allWallets.take(2).toList();
      bloc.add(const WatchWallets());
      await tester.pumpAndSettle();
      expect(title, findsOneWidget);

      repository.wallets = allWallets;
      bloc.add(const WatchWallets());
      await tester.pumpAndSettle();

      final ring = find.byType(AnalysisWalletDistributionRing);
      final ringPaint = find.descendant(
        of: ring,
        matching: find.byType(CustomPaint),
      );
      List<double> slices() => tester
          .widget<AnalysisWalletDistributionRing>(ring)
          .slices
          .map((slice) => slice.amount)
          .toList();

      expect(slices(), [7500, 2500]);
      expect(
        ringPaint,
        paints
          ..arc(strokeCap: StrokeCap.round)
          ..arc(strokeCap: StrokeCap.round),
      );
      final leadingBalance = find.text('7 500 Fc | 75%');
      expect(leadingBalance, findsOneWidget);
      expect(tester.widget<Text>(leadingBalance).maxLines, 1);
      expect(find.text('2 500 Fc | 25%'), findsOneWidget);
      expect(find.text('10 000 Fc'), findsOneWidget);
      expect(find.text('-50 Fc'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Empty'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Bank')).dy,
        lessThan(tester.getTopLeft(find.text('Cash')).dy),
      );

      repository.rows = [
        (walletId: 'bank', currency: 'USD', minor: 300),
        (walletId: 'bank', currency: 'CDF', minor: -300000),
        (walletId: 'cash', currency: 'CDF', minor: 550000),
      ];
      bloc.add(const RefreshWalletBalances());
      await tester.pumpAndSettle();
      expect(slices(), [5500, 4500]);
      expect(find.text('5 500 Fc | 55%'), findsOneWidget);
      expect(find.text('10 000 Fc'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Cash')).dy,
        lessThan(tester.getTopLeft(find.text('Bank')).dy),
      );

      repository.rows = [
        (walletId: 'bank', currency: 'CDF', minor: 500000),
        (walletId: 'cash', currency: 'CDF', minor: 1),
      ];
      bloc.add(const RefreshWalletBalances());
      await tester.pumpAndSettle();
      expect(
        ringPaint,
        paints
          ..arc(strokeCap: StrokeCap.round)
          ..something(
            (name, args) => name == #drawArc && (args[2] as double) > 0,
          ),
      );

      repository.rows = [(walletId: 'bank', currency: 'CDF', minor: 100)];
      bloc.add(const RefreshWalletBalances());
      await tester.pumpAndSettle();
      expect(ringPaint, paintsExactlyCountTimes(#drawCircle, 1));

      repository.rows = [(walletId: 'bank', currency: 'CDF', minor: -100)];
      bloc.add(const RefreshWalletBalances());
      await tester.pumpAndSettle();
      expect(ring, findsNothing);
      expect(find.text('No wallet has a positive balance.'), findsOneWidget);

      repository.wallets = allWallets.take(1).toList();
      bloc.add(const WatchWallets());
      await tester.pumpAndSettle();
      expect(title, findsNothing);
      expect(tester.getSize(card).height, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

class _WalletRepository implements WalletRepository {
  List<WalletBalance> rows = [
    (walletId: 'bank', currency: 'USD', minor: 300),
    (walletId: 'cash', currency: 'CDF', minor: 250000),
    (walletId: 'overdraft', currency: 'CDF', minor: -5000),
    (walletId: 'foreign', currency: 'CAD', minor: 900),
  ];

  @override
  Future<List<WalletBalance>> balances() async => rows;

  List<WalletModel> wallets = const [
    WalletModel(id: 'bank', ownerUid: 'user', name: 'Bank', createdAt: ''),
    WalletModel(id: 'cash', ownerUid: 'user', name: 'Cash', createdAt: ''),
    WalletModel(
      id: 'foreign',
      ownerUid: 'user',
      name: 'Foreign',
      createdAt: '',
    ),
    WalletModel(
      id: 'overdraft',
      ownerUid: 'user',
      name: 'Overdraft',
      createdAt: '',
      archivedAt: '2026-11-25',
    ),
    WalletModel(id: 'empty', ownerUid: 'user', name: 'Empty', createdAt: ''),
  ];

  @override
  Stream<List<WalletModel>> watch() => Stream.value(wallets);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
