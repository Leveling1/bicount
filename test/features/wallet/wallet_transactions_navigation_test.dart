import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_transition.dart';
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
      final search = TextEditingController();
      addTearDown(search.dispose);
      var index = 0;
      String? walletId;
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
                        ? TransactionScreen(
                            data: MainEntity.fromEmpty(),
                            searchController: search,
                            selectedIndexTransaction: 0,
                            onTransactionFilterTap: (_) {},
                            walletId: walletId,
                            onWalletChanged: (id) =>
                                setState(() => walletId = id),
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
      await tester.pump(const Duration(milliseconds: 80));
      expect(index, 2);
      expect(walletId, 'bank');
      expect(find.text('Open wallets'), findsNothing);
      expect(find.byType(WalletScreen), findsOneWidget);
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

      final screen = tester.element(find.byType(TransactionScreen));
      update(() => walletId = 'cash');
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(TransactionScreen)), same(screen));
      expect(
        tester.widget<WalletCard>(find.byType(WalletCard)).walletId,
        'cash',
      );
      await tester.tap(find.byType(PopupMenuButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').hitTestable());
      await tester.pumpAndSettle();
      expect(walletId, 'bank');
      expect(
        tester.widget<WalletCard>(find.byType(WalletCard)).walletId,
        'bank',
      );
      expect(tester.takeException(), isNull);
    },
    skip: !BackendEnvironment.isLocalPreproduction,
  );
}
