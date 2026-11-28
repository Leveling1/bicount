import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_dashboard_builder.dart';
import 'package:bicount/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:bicount/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_month_grid.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_calendar.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'selects today and displays both recurring types on another day',
    (tester) async {
      final today = DateUtils.dateOnly(DateTime.now());
      final anotherDay = DateTime(
        today.year,
        today.month,
        today.day == 1 ? 2 : today.day - 1,
      );
      final theme = AppTheme.darkTheme;
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalysisRecurringCalendar(
                plans: [
                  _plan(
                    'Abonnement aujourd’hui',
                    TransactionTypes.subscriptionCode,
                    today,
                  ),
                  _plan('Salaire', TransactionTypes.salaryCode, anotherDay),
                  _plan(
                    'Abonnement mensuel',
                    TransactionTypes.subscriptionCode,
                    anotherDay,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Abonnement aujourd’hui'), findsOneWidget);
      expect(find.text('Salaire'), findsNothing);
      final targetDay = find.byKey(ValueKey(anotherDay));
      final markerColors = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: targetDay, matching: find.byType(DecoratedBox)),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .where((decoration) => decoration.shape == BoxShape.circle)
          .map((decoration) => decoration.color)
          .whereType<Color>();
      expect(
        markerColors,
        unorderedEquals([
          theme.extension<OtherTheme>()!.income,
          theme.extension<OtherTheme>()!.expense,
        ]),
      );
      await tester.tap(targetDay);
      await tester.pumpAndSettle();
      expect(find.text('Abonnement aujourd’hui'), findsNothing);
      expect(find.text('Salaire'), findsOneWidget);
      expect(find.text('Abonnement mensuel'), findsOneWidget);

      final calendar = find.byType(AnalysisRecurringCalendar);
      final amounts = find.text('25 CDF');
      expect(amounts, findsNWidgets(2));
      final detailRight =
          tester.getRect(calendar).right - AppDimens.paddingMedium;
      for (var i = 0; i < 2; i++) {
        expect(tester.getRect(amounts.at(i)).right, detailRight);
        expect(tester.widget<Text>(amounts.at(i)).textAlign, TextAlign.end);
      }

      final context = tester.element(calendar);
      final material = MaterialLocalizations.of(context);
      final emptyDay = [1, 2, 3]
          .map((day) => DateTime(today.year, today.month, day))
          .firstWhere((day) => day != today && day != anotherDay);
      await tester.tap(find.byKey(ValueKey(emptyDay)));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsNothing);
      expect(find.text(material.formatFullDate(emptyDay)), findsNothing);
      expect(find.text('Aucune échéance prévue ce jour.'), findsNothing);
      expect(find.text('Revenus'), findsOneWidget);
      expect(find.text('Dépenses'), findsOneWidget);
      expect(find.text('Salaire'), findsNothing);

      await tester.tap(find.byTooltip(material.nextMonthTooltip));
      await tester.pumpAndSettle();
      expect(
        find.text(
          material.formatMonthYear(DateTime(today.year, today.month + 1)),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip(material.previousMonthTooltip));
      await tester.pumpAndSettle();
      expect(find.text('Abonnement aujourd’hui'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the calendar grid spans the full Analysis viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AnalysisBloc>.value(value: _LoadedAnalysisBloc()),
          BlocProvider<MainBloc>.value(value: _EmptyMainBloc()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AnalysisScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(AnalysisMonthGrid));
    expect(rect.left, 0);
    expect(rect.right, 360);
    expect(tester.takeException(), isNull);
  });
}

class _LoadedAnalysisBloc extends Fake implements AnalysisBloc {
  @override
  final state = AnalysisState(
    status: AnalysisStatus.success,
    period: AnalysisPeriod.month30,
    dashboard: const AnalysisDashboardBuilder().build(
      const AnalysisSourceData(
        transactions: [],
        debts: [],
        recurringTransferts: [],
      ),
      AnalysisPeriod.month30,
      CurrencyConfigEntity.fallback(),
    ),
  );

  @override
  Stream<AnalysisState> get stream => const Stream.empty();
}

class _EmptyMainBloc extends Fake implements MainBloc {
  @override
  MainState get state => MainInitial();

  @override
  Stream<MainState> get stream => const Stream.empty();
}

RecurringTransfertModel _plan(String title, int type, DateTime start) =>
    RecurringTransfertModel(
      uid: 'user',
      recurringTransfertTypeId: type,
      title: title,
      amount: 25,
      currency: 'CDF',
      senderId: '',
      beneficiaryId: '',
      frequency: Frequency.monthly,
      startDate: start.toIso8601String(),
      nextDueDate: start.toIso8601String(),
    );
