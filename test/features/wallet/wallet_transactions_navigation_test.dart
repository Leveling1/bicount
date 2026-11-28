import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_stack.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_transition.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_card.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _WalletRepository implements WalletRepository {
  @override
  Stream<List<WalletModel>> watch() => Stream.value(const [
    WalletModel(
      id: 'principal',
      ownerUid: 'user',
      name: 'Principal',
      createdAt: '-',
      isDefault: true,
    ),
    WalletModel(id: 'bank', ownerUid: 'user', name: 'Bank', createdAt: '-'),
    WalletModel(id: 'cash', ownerUid: 'user', name: 'Cash', createdAt: '-'),
  ]);
  @override
  Future<List<WalletBalance>> balances() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'wallet action opens Transactions directly with its wallet selected',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(410, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final search = TextEditingController();
      final tabs = PageController(initialPage: 1);
      addTearDown(search.dispose);
      addTearDown(tabs.dispose);
      var index = 0;
      String? walletId;
      final data = MainEntity.fromEmpty();
      data.transactions.add(
        TransactionModel(
          tid: 'hidden',
          uid: data.user.uid,
          gtid: 'hidden',
          name: 'Outside the displayed wallets',
          type: TransactionTypes.expenseCode,
          senderId: data.user.uid,
          senderWalletId: 'not-displayed',
          beneficiaryId: 'friend',
          date: '2026-11-23T12:00:00',
          amount: 10,
          currency: 'CDF',
          note: '',
        ),
      );
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider(
            create: (_) =>
                WalletBloc(_WalletRepository())..add(const WatchWallets()),
            child: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return HomeWalletTransition(
                  enabled: index == 0,
                  hasSharedContainer: true,
                  selectedIndex: index,
                  onSelectTab: (target) => setState(() => index = target),
                  onSelectCoveredTab: (target) =>
                      setState(() => index = target),
                  onOpenWalletTransactions: (id) =>
                      setState(() => walletId = id),
                  builder: (openWallets) => Scaffold(
                    body: index == 2
                        ? PageView(
                            controller: tabs,
                            children: [
                              const Text('Analysis'),
                              TransactionScreen(
                                data: data,
                                searchController: search,
                                selectedIndexTransaction: 0,
                                onTransactionFilterTap: (_) {},
                                walletId: walletId,
                                onWalletChanged: (id) =>
                                    setState(() => walletId = id),
                              ),
                              const Text('Profile'),
                            ],
                          )
                        : Center(
                            child: TextButton(
                              onPressed: openWallets,
                              child: const Text('Open wallets'),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open wallets'));
      await tester.pumpAndSettle();
      final action = find.descendant(
        of: find.byKey(const ValueKey('bank')),
        matching: find.byTooltip('Transaction'),
      );
      expect(action, findsOneWidget);
      final svg = tester.widget<SvgPicture>(
        find.descendant(of: action, matching: find.byType(SvgPicture)),
      );
      expect(
        (svg.bytesLoader as SvgAssetLoader).assetName,
        IconLinks.transaction,
      );
      await tester.tap(action);
      await tester.pump();
      expect(index, 2);
      expect(walletId, 'bank');
      expect(find.text('Open wallets'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(WalletScreen), findsNothing);
      expect(
        tester
            .widget<CustomBottomNavigationBar>(
              find.byType(CustomBottomNavigationBar),
            )
            .selectedIndex,
        2,
      );
      expect(
        tester.widget<WalletCard>(find.byType(WalletCard)).walletId,
        'bank',
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(WalletCard)),
      )!;
      expect(find.text(l10n.walletAll), findsNothing);
      expect(find.text(l10n.walletNoMovements), findsNothing);
      expect(
        tester
            .widget<Text>(find.text(l10n.transactionNoTransactionsFound))
            .textAlign,
        TextAlign.center,
      );

      final screen = tester.element(find.byType(TransactionScreen));
      String? selectedWalletId() =>
          tester.widget<WalletCard>(find.byType(WalletCard)).walletId;
      update(() => walletId = 'cash');
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(TransactionScreen)), same(screen));
      expect(selectedWalletId(), 'cash');
      await tester.tap(find.byType(PopupMenuButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').hitTestable());
      await tester.pumpAndSettle();
      expect(walletId, 'bank');
      expect(selectedWalletId(), 'bank');

      update(() => walletId = null);
      await tester.pumpAndSettle();
      final stack = find.byType(WalletCardStack);
      expect(selectedWalletId(), 'principal');
      for (final (direction, expected) in [
        (1, 'cash'), // First to last, then forward across the same boundary.
        (-1, 'principal'),
        (-1, 'bank'),
        (1, 'principal'),
      ]) {
        await tester.fling(stack, Offset(direction * 185, 0), 700);
        await tester.pumpAndSettle();
        expect(tabs.page, 1);
        expect(walletId, expected);
        expect(selectedWalletId(), expected);
      }
      expect(tester.takeException(), isNull);
    },
    skip: !BackendEnvironment.walletsEnabled,
  );
}
