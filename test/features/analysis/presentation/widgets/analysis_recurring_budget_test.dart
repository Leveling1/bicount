import 'dart:async';

import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_popup_menu_item.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:bicount/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_budget_card.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets(
    'shows the confirmed salary and filters its month and year independently',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final today = DateTime.now();
      final month = DateTime(today.year, today.month);
      final due = today.day <= 7
          ? DateTime(today.year, today.month + 1, 0)
          : month;
      const longTitle = 'Abonnement annuel à la salle de sport du quartier';
      final currency = _CurrencyCubit();
      final salary = _plan('Salaire', 1000, due, isIncome: true);
      final analysis = _PeriodAnalysisBloc(
        AnalysisSourceData(
          debts: const [],
          recurringTransferts: [
            salary,
            _plan('Loyer', 430, due),
            _plan(longTitle, 50, due),
            _plan('Netflix', 14, due),
            _plan('Stockage', 6, due),
          ],
          transactions: [
            TransactionModel(
              uid: 'owner',
              gtid: 'salary',
              name: 'Salaire',
              type: TransactionTypes.salaryCode,
              senderId: 'contact',
              beneficiaryId: 'owner',
              date: due.toIso8601String(),
              recurringTransfertId: salary.recurringTransfertId,
              recurringOccurrenceDate: due.toIso8601String(),
              amount: 950,
              currency: 'USD',
              note: '',
            ),
          ],
        ),
        currency.state.config,
      );
      addTearDown(analysis.controller.close);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CurrencyCubit>.value(value: currency),
            BlocProvider<AnalysisBloc>.value(value: analysis),
            BlocProvider<MainBloc>.value(
              value: _LoadedMainBloc(analysis.source),
            ),
          ],
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
            home: const Scaffold(body: AnalysisScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(
        AnalysisRecurringBudgetCard,
        skipOffstage: false,
      );
      Finder inCard(String label) => find.descendant(
        of: card,
        matching: find.text(label, skipOffstage: false),
        skipOffstage: false,
      );
      String usd(double amount) => NumberFormatUtils.formatCurrency(
        amount,
        locale: 'fr',
        currencyCode: 'USD',
      );
      expect(inCard(usd(450)), findsNWidgets(2));
      expect(inCard('Revenus reçus'), findsOneWidget);
      expect(inCard('− ${usd(14)}'), findsOneWidget);

      final longLabel = inCard(longTitle);
      await Scrollable.ensureVisible(tester.element(longLabel), alignment: 0.5);
      await tester.pumpAndSettle();
      expect(tester.getRect(longLabel).right, lessThan(320));
      expect(tester.getRect(longLabel).height, greaterThan(24));
      final others = inCard('Autres charges');
      await Scrollable.ensureVisible(tester.element(others), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(others);
      await tester.pumpAndSettle();
      expect(find.text('Stockage').hitTestable(), findsOneWidget);
      expect(find.text(usd(6)).hitTestable(), findsOneWidget);
      Navigator.of(tester.element(find.text('Stockage').hitTestable())).pop();
      await tester.pumpAndSettle();

      final weekChip = find.text('7J', skipOffstage: false);
      await tester.ensureVisible(weekChip);
      await tester.pumpAndSettle();
      await tester.tap(weekChip);
      await tester.pumpAndSettle();
      expect(analysis.state.period, AnalysisPeriod.week7);
      expect(inCard(usd(450)), findsNWidgets(2));

      Future<void> selectBudgetOption(String control, String label) async {
        final field = find.descendant(
          of: find.byKey(ValueKey(control), skipOffstage: false),
          matching: find.byType(PopupMenuButton<int>, skipOffstage: false),
          skipOffstage: false,
        );
        await Scrollable.ensureVisible(tester.element(field), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(field);
        await tester.pumpAndSettle();
        final entry = find.widgetWithText(AppPopupMenuItem<int>, label);
        await tester.ensureVisible(entry);
        await tester.pumpAndSettle();
        await tester.tap(entry);
        await tester.pumpAndSettle();
      }

      await selectBudgetOption('recurring_budget_year', '${today.year + 1}');
      expect(inCard(usd(500)), findsNWidgets(2));
      final otherMonth = DateTime(
        today.year + 1,
        today.month == 12 ? 1 : today.month + 1,
      );
      await selectBudgetOption(
        'recurring_budget_month',
        DateFormat.MMMM('fr').format(otherMonth),
      );
      expect(card, findsNothing);
      expect(
        find.byKey(
          const ValueKey('recurring_budget_month'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(analysis.state.period, AnalysisPeriod.week7);
      expect(tester.takeException(), isNull);
    },
  );
}

class _PeriodAnalysisBloc extends Fake implements AnalysisBloc {
  _PeriodAnalysisBloc(this.source, this.config) {
    state = _stateFor(AnalysisPeriod.month30);
  }

  final AnalysisSourceData source;
  final CurrencyConfigEntity config;
  final controller = StreamController<AnalysisState>.broadcast();

  @override
  late AnalysisState state;

  @override
  Stream<AnalysisState> get stream => controller.stream;

  @override
  void add(AnalysisEvent event) {
    if (event is AnalysisPeriodChanged) {
      state = _stateFor(event.period);
      controller.add(state);
    }
  }

  AnalysisState _stateFor(AnalysisPeriod period) => AnalysisState(
    status: AnalysisStatus.success,
    period: period,
    dashboard: const AnalysisDashboardBuilder().build(source, period, config),
  );
}

class _LoadedMainBloc extends Fake implements MainBloc {
  _LoadedMainBloc(AnalysisSourceData source)
    : state = MainLoaded(
        MainEntity.fromEmpty()
          ..recurringTransferts.addAll(source.recurringTransferts)
          ..transactions.addAll(source.transactions),
      );

  @override
  final MainState state;

  @override
  Stream<MainState> get stream => const Stream.empty();
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
