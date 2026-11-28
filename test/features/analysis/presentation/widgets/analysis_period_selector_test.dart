import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/utils/pinned_header_delegate.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_period_selector.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_range_calendar.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('styles and saves a calendar range in the bottom sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    addTearDown(tester.view.reset);
    var period = AnalysisPeriod.month30;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedHeaderDelegate(
                  padding: EdgeInsets.zero,
                  child: StatefulBuilder(
                    builder: (context, setState) => AnalysisPeriodSelector(
                      selectedPeriod: period,
                      onSelected: (value) => setState(() => period = value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(AnalysisPeriodSelector));
    final material = MaterialLocalizations.of(context);
    final start = DateTime(2026, 11, 3);
    final end = DateTime(2026, 11, 18);

    expect(find.text('Tout'), findsNothing);
    expect(find.text('7J'), findsOneWidget);
    expect(find.text('30J'), findsOneWidget);
    expect(find.text('90J'), findsOneWidget);
    final row = find.byType(SingleChildScrollView);
    final firstChip = find.widgetWithText(ChoiceChip, '7J');
    expect(tester.getRect(row).left, 0);
    expect(tester.getRect(row).right, 360);
    expect(tester.getRect(firstChip).left, AppDimens.paddingMedium);
    await tester.drag(row, const Offset(-48, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(firstChip).left, lessThan(0));

    final scrollable = find.descendant(
      of: row,
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    final endChip = find.widgetWithText(ChoiceChip, 'Période');
    expect(
      tester.getRect(row).right - tester.getRect(endChip).right,
      AppDimens.paddingMedium,
    );
    await tester.tap(find.text('Période'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AnalysisRangeCalendar), findsOneWidget);
    expect(find.byType(CloseButton), findsNothing);
    final inactiveSave = find.widgetWithText(TextButton, 'Enregistrer');
    expect(tester.widget<TextButton>(inactiveSave).onPressed, isNull);
    expect(find.byType(CustomButton), findsNothing);
    await tester.tap(find.byTooltip(material.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(CustomFormTextField).hitTestable(),
      ),
      findsNWidgets(2),
    );
    final fields = find.byType(TextField);
    final save = find.byType(CustomButton);
    await tester.enterText(fields.first, material.formatCompactDate(start));
    await tester.enterText(
      fields.last,
      material.formatCompactDate(DateTime(2026, 11, 2)),
    );
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text(material.invalidDateRangeLabel), findsOneWidget);
    expect(period, AnalysisPeriod.month30);

    await tester.tap(find.byTooltip(material.calendarModeButtonLabel));
    await tester.pumpAndSettle();
    expect(find.byType(AnalysisRangeCalendar), findsOneWidget);
    await tester.tap(find.byTooltip(material.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(fields.first).controller!.text,
      material.formatCompactDate(start),
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 380);
    await tester.pumpAndSettle();
    await tester.ensureVisible(fields.last);
    await tester.enterText(fields.last, material.formatCompactDate(end));
    await tester.ensureVisible(save);
    await tester.tap(save);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();

    final range = DateTimeRange(start: start, end: end);
    expect(period.dateRange, range);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Période'), findsNothing);
    final dateChip = find.widgetWithText(ChoiceChip, '3 nov. – 18 nov. 2026');
    expect(tester.widget<ChoiceChip>(dateChip).selected, isTrue);

    await tester.tap(dateChip);
    await tester.pumpAndSettle();
    expect(find.byType(AnalysisRangeCalendar), findsOneWidget);
    expect(find.byType(CloseButton), findsNothing);
    expect(save, findsOneWidget);
    expect(inactiveSave, findsNothing);
    expect(tester.getSize(save), const Size(144, 44));

    final primary = AppTheme.darkTheme.colorScheme.primary;
    Finder day(DateTime date) => find.byKey(ValueKey(date));
    Iterable<BoxDecoration> dayDecorations(DateTime date) => tester
        .widgetList<DecoratedBox>(
          find.descendant(of: day(date), matching: find.byType(DecoratedBox)),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>();

    for (final date in [start, end]) {
      expect(
        dayDecorations(date).any(
          (decoration) =>
              decoration.shape == BoxShape.circle &&
              decoration.color == primary,
        ),
        isTrue,
      );
    }
    final dayBetween = day(DateTime(2026, 11, 12));
    final dayFeedback = tester.widget<InkWell>(
      find.descendant(of: dayBetween, matching: find.byType(InkWell)),
    );
    expect(dayFeedback.customBorder, const CircleBorder());
    final dayBackground = find.descendant(
      of: dayBetween,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.color == primary.withValues(alpha: 0.10),
      ),
    );
    expect(dayBackground, findsOneWidget);

    await tester.tap(find.byTooltip(material.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(fields.first).controller!.text,
      material.formatCompactDate(start),
    );
    expect(
      tester.widget<TextField>(fields.last).controller!.text,
      material.formatCompactDate(end),
    );
    await tester.tap(find.byTooltip(material.calendarModeButtonLabel));
    await tester.pumpAndSettle();
    final newStart = DateTime(2026, 11, 5);
    final newEnd = DateTime(2026, 11, 10);
    await tester.tap(day(newStart));
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(inactiveSave).onPressed, isNull);
    await tester.tap(day(newEnd));
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(period.dateRange, DateTimeRange(start: newStart, end: newEnd));
  });
}
