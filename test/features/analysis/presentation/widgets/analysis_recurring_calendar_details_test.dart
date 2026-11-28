import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_recurring_calendar.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_sheet.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_view.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('both calendar rows open the shared recurring plan detail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateTime(
      today.year,
      today.month,
      today.day == 1 ? 2 : today.day - 1,
    );
    final plans = [
      _plan('income', 'Salaire', TransactionTypes.salaryCode, date),
      _plan('charge', 'Abonnement', TransactionTypes.subscriptionCode, date),
    ];
    final data = MainEntity.fromEmpty()..recurringTransferts.addAll(plans);
    await tester.pumpWidget(
      RepositoryProvider<RecurringTransfertRepositoryImpl>.value(
        value: _RecurringRepository(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<MainBloc>.value(value: _LoadedMainBloc(data)),
            BlocProvider<CurrencyCubit>.value(value: _CurrencyCubit()),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnalysisRecurringCalendar(plans: plans),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey(date)));
    await tester.pumpAndSettle();

    for (final (plan, scope) in [
      (plans[0], RecurringPlanScope.income),
      (plans[1], RecurringPlanScope.charge),
    ]) {
      final row = find.text(plan.title);
      await tester.ensureVisible(row);
      final pressSurface = find.ancestor(
        of: row,
        matching: find.byType(BicountPressable),
      );
      final surfaceBounds = tester.getRect(pressSurface);
      final labelBounds = tester.getRect(row);
      final press = await tester.startGesture(tester.getCenter(row));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 120));

      expect(tester.getRect(pressSurface), surfaceBounds);
      expect(tester.getRect(row).width, lessThan(labelBounds.width));
      final fill = find.descendant(
        of: pressSurface,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is ShapeDecoration &&
              (widget.decoration as ShapeDecoration).color ==
                  appPressedColor(AppTheme.darkTheme.primaryColor),
        ),
      );
      expect(fill, findsOneWidget);
      expect(tester.getRect(fill), surfaceBounds);

      await press.up();
      await tester.pumpAndSettle();

      final detail = find.byType(RecurringPlanDetailSheet);
      expect(tester.widget<RecurringPlanDetailSheet>(detail).scope, scope);
      expect(
        tester.widget<RecurringPlanDetailSheet>(detail).recurringTransfertId,
        plan.recurringTransfertId,
      );
      final view = tester.widget<RecurringPlanDetailView>(
        find.byType(RecurringPlanDetailView),
      );
      expect(view.summary.recurringTransfert.title, plan.title);
      expect(view.onPauseActionPressed, isNotNull);

      final detailContext = tester.element(detail);
      final l10n = AppLocalizations.of(detailContext)!;
      final pauseButton = find.text(l10n.recurringPlanPauseCta);
      await tester.ensureVisible(pauseButton);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();
      final pauseNotice = find.text(l10n.recurringPlanPauseNotice);
      expect(pauseNotice, findsOneWidget);
      Navigator.of(tester.element(pauseNotice)).pop();
      await tester.pumpAndSettle();

      final bloc = detailContext.read<RecurringTransfertBloc>();
      Navigator.of(detailContext).pop();
      await tester.pumpAndSettle();
      expect(bloc.isClosed, isTrue);
      expect(detail, findsNothing);
      expect(row, findsOneWidget);
    }
  });
}

RecurringTransfertModel _plan(
  String id,
  String title,
  int type,
  DateTime date,
) => RecurringTransfertModel(
  recurringTransfertId: id,
  uid: 'user',
  recurringTransfertTypeId: type,
  title: title,
  amount: 25,
  currency: 'CDF',
  senderId: '',
  beneficiaryId: '',
  frequency: Frequency.monthly,
  startDate: date.toIso8601String(),
  nextDueDate: date.toIso8601String(),
);

class _RecurringRepository extends Fake
    implements RecurringTransfertRepositoryImpl {}

class _LoadedMainBloc extends Fake implements MainBloc {
  _LoadedMainBloc(MainEntity data) : state = MainLoaded(data);

  @override
  final MainState state;

  @override
  Stream<MainState> get stream => const Stream.empty();
}

class _CurrencyCubit extends Fake implements CurrencyCubit {
  @override
  CurrencyState get state => const CurrencyState.initial();

  @override
  Stream<CurrencyState> get stream => const Stream.empty();
}
