import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _CurrencyCubit extends Cubit<CurrencyState> implements CurrencyCubit {
  _CurrencyCubit() : super(const CurrencyState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TransactionBloc extends Bloc<TransactionEvent, TransactionState>
    implements TransactionBloc {
  _TransactionBloc() : super(TransactionInitial()) {
    on<CreateTransactionEvent>((event, _) => submitted.add(event));
  }

  final submitted = <CreateTransactionEvent>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'expense sheet submits the wallet selected at opening or the manual choice',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() async {
        await Supabase.initialize(
          url: 'http://127.0.0.1:1',
          publishableKey: 'unused-test-key',
        );
      });
      addTearDown(Supabase.instance.dispose);

      final bloc = _TransactionBloc();
      addTearDown(bloc.close);
      var activeWallet = 'bank';
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CurrencyCubit>(create: (_) => _CurrencyCubit()),
            BlocProvider<TransactionBloc>.value(value: bloc),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => openTransactionSheet(
                    context,
                    MainEntity.fromEmpty(),
                    prefilledExpenseWalletId: activeWallet,
                    prefilledFriend: FriendsModel(
                      sid: 'friend',
                      username: 'Camille',
                      email: '',
                      image: '',
                      relationType: 0,
                    ),
                  ),
                  child: const Text('Open expense'),
                ),
              ),
            ),
          ),
        ),
      );

      final picker = find.byType(WalletPicker);
      for (final (initialWallet, manualWallet) in [
        ('bank', null),
        ('cash', 'savings'),
      ]) {
        activeWallet = initialWallet;
        await tester.tap(find.text('Open expense'));
        await tester.pumpAndSettle();
        expect(tester.widget<WalletPicker>(picker).value, initialWallet);
        activeWallet = 'different-card';
        if (manualWallet != null) {
          tester.widget<WalletPicker>(picker).onChanged(manualWallet);
          await tester.pumpAndSettle();
          expect(tester.widget<WalletPicker>(picker).value, manualWallet);
        }
        tester
                .widget<CustomAmountField>(find.byType(CustomAmountField))
                .amount
                .text =
            '25';
        final l10n = AppLocalizations.of(tester.element(picker))!;
        final title = find.byWidgetPredicate(
          (widget) =>
              widget is CustomFormField && widget.label == l10n.commonTitle,
        );
        tester.widget<CustomFormField>(title).controller!.text = 'Courses';
        final save = find.text(l10n.commonSave);
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(
          bloc.submitted.last.transaction.walletId,
          manualWallet ?? initialWallet,
        );

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
    },
    skip: !BackendEnvironment.isLocalPreproduction,
  );
}
