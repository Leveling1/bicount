import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/services/transaction_direction_service.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/quick_action_button.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder pressTransform(Finder surface) =>
    find.descendant(of: surface, matching: find.byType(Transform)).first;

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final theme = AppTheme.lightTheme.copyWith(platform: platform);

    testWidgets('${platform.name} quick action scales its card background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: QuickActionButton(
                icon: Icons.arrow_upward,
                label: 'Dépense',
                color: Colors.red,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final target = find.byType(BicountPressable);
      final transform = pressTransform(target);
      final background = find.descendant(
        of: transform,
        matching: find.byWidgetPredicate(
          (widget) => widget is Material && widget.color == theme.cardColor,
        ),
      );
      final bounds = tester.getRect(background);
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 110));
      await tester.pump(const Duration(milliseconds: 55));

      expect(tester.getRect(background).width, closeTo(bounds.width * .97, .1));
      expect(tester.widget<Transform>(transform).transformHitTests, isFalse);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(background), bounds);
    });

    testWidgets(
      '${platform.name} transaction row responds during a quick tap',
      (tester) async {
        var opens = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TransactionCard(
                  transaction: TransactionEntity(
                    tid: 'entry',
                    gtid: 'entry',
                    name: 'Courses',
                    type: 0,
                    date: DateTime(2026, 11, 27),
                    amount: 25,
                    currency: 'EUR',
                    sender: 'owner',
                    beneficiary: 'shop',
                    note: '',
                  ),
                  walletTransferDirection: const TransactionDirection(
                    sign: TransactionSign.negative,
                    origin: TransactionOrigin.external,
                  ),
                  onTap: () {
                    opens++;
                    showCustomBottomSheet<void>(
                      context: context,
                      minHeight: .95,
                      child: const Text('Détail'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final target = find.byType(BicountPressable, skipOffstage: false);
        await tester.tap(target);
        expect(opens, 1);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        final transform = tester.widget<Transform>(pressTransform(target));
        expect(transform.transform.storage[0], lessThan(.99));
        final tint = find.descendant(
          of: target,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.position == DecorationPosition.foreground &&
                widget.decoration is ShapeDecoration &&
                (widget.decoration as ShapeDecoration).color!.a > .05,
          ),
        );
        expect(tint, findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Détail'), findsOneWidget);
      },
    );
  }
}
