import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/themes/dropdown_chevron_theme.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CurrencyCubit extends Cubit<CurrencyState> implements CurrencyCubit {
  _CurrencyCubit()
    : super(CurrencyState(config: CurrencyConfigEntity.fallback()));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletRepository implements WalletRepository {
  static const _wallets = [
    WalletModel(id: 'cash', ownerUid: 'user', name: 'Cash', createdAt: '-'),
    WalletModel(id: 'bank', ownerUid: 'user', name: 'Bank', createdAt: '-'),
  ];

  final transfers = <(String, String, double, String, String)>[];

  @override
  Stream<List<WalletModel>> watch() => Stream.value(_wallets);

  @override
  Future<List<WalletBalance>> balances() async => [];

  @override
  Future<void> transfer({
    required WalletModel from,
    required WalletModel to,
    required double amount,
    required String currency,
    required String title,
  }) async {
    transfers.add((from.id, to.id, amount, currency, title));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'wallet transfers open in a bottom sheet and use the entered amount and currency',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 680);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      final repository = _WalletRepository();
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CurrencyCubit>(create: (_) => _CurrencyCubit()),
            BlocProvider(
              create: (_) => WalletBloc(repository)..add(const WatchWallets()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme.copyWith(
              extensions: const [DropdownChevronTheme(size: 20)],
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WalletScreen(onOpenTransactions: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(WalletScreen)),
      )!;
      await tester.tap(find.byTooltip(l10n.walletTransfer));
      await tester.pumpAndSettle();

      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(CustomDropdownMenu), findsNWidgets(2));
      final closedChevrons = find
          .descendant(of: sheet, matching: find.byIcon(Icons.expand_more))
          .hitTestable();
      expect(closedChevrons, findsNWidgets(3));
      expect(
        tester.widgetList<Icon>(closedChevrons).map((icon) => icon.size),
        everyElement(20.0),
      );
      final amount = find.byType(CustomAmountField);
      final save = find.widgetWithText(CustomButton, l10n.commonSave);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text(l10n.validationAmountGreaterThanZero), findsOneWidget);
      expect(repository.transfers, isEmpty);

      await tester.ensureVisible(amount);
      final amountField = find.descendant(
        of: find.byType(AmountNumber),
        matching: find.byType(EditableText),
      );
      await tester.enterText(amountField, '24,50');
      tester.view.viewInsets = const FakeViewPadding(bottom: 210);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      final currency = find.descendant(
        of: find.byType(CurrencyField),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(currency);
      await tester.tap(currency);
      await tester.pumpAndSettle();
      expect(
        find
            .descendant(of: amount, matching: find.byIcon(Icons.expand_less))
            .hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.text('USD').hitTestable().last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.transfers, [
        ('cash', 'bank', 24.50, 'USD', 'Transfer from Cash to Bank'),
      ]);
      expect(sheet, findsNothing);
    },
  );
}
