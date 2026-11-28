import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_choice_chip.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_fab.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_debt_section.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double pressScale(WidgetTester tester, Finder control) {
  final press = find
      .ancestor(of: control, matching: find.byType(BicountPressable))
      .first;
  final transform = find
      .descendant(of: press, matching: find.byType(Transform))
      .first;
  return tester.widget<Transform>(transform).transform.storage[0];
}

Widget app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.lightTheme,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('the floating plus scales and invokes its original action', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      app(
        MainShellFab(
          selectedIndex: 2,
          transaction: 1,
          onPressed: () => actions++,
        ),
      ),
    );
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    expect(actions, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 24));
    expect(pressScale(tester, fab), lessThan(.99));
    await tester.pumpAndSettle();
    expect(pressScale(tester, fab), 1);
  });

  testWidgets('a chip under the wallet theme cancels feedback on a drag', (
    tester,
  ) async {
    var selections = 0;
    await tester.pumpWidget(
      app(
        Center(
          child: CustomChoiceChip(
            label: 'Mensuel',
            selected: false,
            onSelected: (_) => selections++,
          ),
        ),
        theme: AppTheme.walletCorners(AppTheme.lightTheme),
      ),
    );
    final chip = find.byType(ChoiceChip);
    final gesture = await tester.startGesture(tester.getCenter(chip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 55));
    expect(pressScale(tester, chip), closeTo(.97, .001));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(pressScale(tester, chip), 1);
    await gesture.up();
    expect(selections, 0);
    await tester.tap(chip);
    expect(selections, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('transaction switches animate only while enabled', (
    tester,
  ) async {
    var actions = 0;
    final due = TextEditingController();
    final amount = TextEditingController();
    final currency = TextEditingController();
    addTearDown(due.dispose);
    addTearDown(amount.dispose);
    addTearDown(currency.dispose);

    Widget section(bool enabled) => app(
      TransferFormDebtSection(
        isDebt: false,
        subtitle: 'Prêt',
        enabled: enabled,
        dueDateController: due,
        expectedAmountController: amount,
        expectedCurrencyController: currency,
        onDebtChanged: (_) => actions++,
        amount: '25',
      ),
    );

    await tester.pumpWidget(section(false));
    final tile = find.byType(SwitchListTile);
    await tester.tap(find.text('Prêt'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 24));
    expect(actions, 0);
    expect(pressScale(tester, tile), 1);

    await tester.pumpWidget(section(true));
    await tester.tap(find.text('Prêt'));
    expect(actions, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 24));
    expect(pressScale(tester, tile), lessThan(.99));
    await tester.pumpAndSettle();
  });

  testWidgets('the automatically implied app-bar button can still pop', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (context) =>
                    const Scaffold(appBar: CustomAppBar(title: 'Détail')),
              ),
            ),
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    final back = find.byType(BackButton);
    expect(
      find.ancestor(of: back, matching: find.byType(BicountPressable)),
      findsOneWidget,
    );
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Détail'), findsNothing);
  });
}
