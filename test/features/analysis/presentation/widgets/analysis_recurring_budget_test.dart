import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_budget_card.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_calendar.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fits a narrow screen and follows the calendar month', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = DateTime.now();
    final month = DateTime(today.year, today.month);
    const longTitle = 'Abonnement annuel à la salle de sport du quartier';
    final currency = _CurrencyCubit();

    await tester.pumpWidget(
      BlocProvider<CurrencyCubit>.value(
        value: currency,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalysisRecurringCalendar(
                plans: [
                  _plan('Salaire', 1000, month, isIncome: true),
                  _plan('Loyer', 430, month),
                  _plan(longTitle, 50, month),
                  _plan('Netflix', 14, month),
                  _plan('Stockage', 6, month),
                ],
                monthFooterBuilder: (context, month, entries) =>
                    AnalysisRecurringBudgetCard(month: month, agenda: entries),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = find.byType(AnalysisRecurringBudgetCard);
    Finder inCard(String label) =>
        find.descendant(of: card, matching: find.text(label));
    String usd(double amount) => NumberFormatUtils.formatCurrency(
      amount,
      locale: 'fr',
      currencyCode: 'USD',
    );
    expect(inCard('Budget récurrent'), findsOneWidget);
    expect(inCard(usd(500)), findsNWidgets(2));
    expect(inCard('− ${usd(14)}'), findsOneWidget);

    final longLabel = inCard(longTitle);
    await tester.ensureVisible(longLabel);
    expect(tester.getRect(longLabel).right, lessThan(320));
    expect(tester.getRect(longLabel).height, greaterThan(24));
    final others = inCard('Autres charges');
    await tester.ensureVisible(others);
    await tester.tap(others);
    await tester.pumpAndSettle();
    expect(find.text('Stockage').hitTestable(), findsOneWidget);
    expect(find.text(usd(6)).hitTestable(), findsOneWidget);
    Navigator.of(tester.element(find.text('Stockage').hitTestable())).pop();
    await tester.pumpAndSettle();

    final material = MaterialLocalizations.of(
      tester.element(find.byType(AnalysisRecurringCalendar)),
    );
    final nextMonth = find.byTooltip(material.nextMonthTooltip);
    await tester.ensureVisible(nextMonth);
    await tester.tap(nextMonth);
    await tester.pumpAndSettle();
    expect(find.text('Budget récurrent'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

RecurringTransfertModel _plan(
  String title,
  double amount,
  DateTime start, {
  bool isIncome = false,
}) => RecurringTransfertModel(
  uid: 'owner',
  recurringTransfertTypeId: isIncome
      ? TransactionTypes.salaryCode
      : TransactionTypes.subscriptionCode,
  title: title,
  amount: amount,
  currency: 'USD',
  senderId: 'owner',
  beneficiaryId: 'contact',
  frequency: isIncome ? Frequency.yearly : Frequency.monthly,
  startDate: start.toIso8601String(),
  nextDueDate: start.toIso8601String(),
);

class _CurrencyCubit extends Fake implements CurrencyCubit {
  @override
  CurrencyState get state => CurrencyState(
    config: CurrencyConfigEntity.fallback().copyWith(
      referenceCurrencyCode: 'USD',
    ),
  );

  @override
  Stream<CurrencyState> get stream => const Stream.empty();
}
