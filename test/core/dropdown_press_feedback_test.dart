import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/wallet_corner_theme.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final shared in [false, true]) {
    testWidgets(
      'wallet press tint and selection in the ${shared ? 'shared' : 'classic'} dropdown',
      (tester) async {
        var selection = 'primary';
        final theme = AppTheme.lightTheme.copyWith(
          platform: TargetPlatform.windows,
        );
        final tint = appPressedColor(theme.primaryColor);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: WalletCornerTheme(
                child: WalletDropdown(
                  label: 'Pay from',
                  value: selection,
                  wallets: const [
                    WalletModel(
                      id: 'primary',
                      ownerUid: 'owner',
                      name: 'Main wallet',
                      createdAt: '',
                    ),
                    WalletModel(
                      id: 'other',
                      ownerUid: 'owner',
                      name: 'Second wallet',
                      createdAt: '',
                    ),
                  ],
                  useSharedMenu: shared,
                  onChanged: (value) => selection = value,
                ),
              ),
            ),
          ),
        );

        final decorator = find.byType(InputDecorator).first;
        final idleDecoration = tester
            .widget<InputDecorator>(decorator)
            .decoration;
        final scopedTheme = Theme.of(tester.element(decorator));
        final baseFill = shared
            ? scopedTheme.dropdownMenuTheme.inputDecorationTheme?.fillColor
            : scopedTheme.inputDecorationTheme.fillColor;
        final anchor = shared
            ? find.byType(TextField).first
            : find.text('Main wallet').hitTestable().first;
        final anchorPress = await tester.startGesture(tester.getCenter(anchor));
        await tester.pump();
        final pressedDecoration = tester
            .widget<InputDecorator>(decorator)
            .decoration;
        expect(
          pressedDecoration.fillColor,
          Color.alphaBlend(
            tint,
            idleDecoration.fillColor ?? baseFill ?? Colors.transparent,
          ),
        );
        expect(pressedDecoration.border, idleDecoration.border);
        await anchorPress.up();
        await tester.pumpAndSettle();

        if (shared) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final entry = find
              .widgetWithText(MenuItemButton, 'Second wallet')
              .hitTestable()
              .last;
          final style = Theme.of(tester.element(entry)).menuButtonTheme.style!;
          expect(style.overlayColor!.resolve({WidgetState.pressed}), tint);
          expect(style.overlayColor!.resolve({WidgetState.focused}), isNotNull);
          expect(style.shape!.resolve({}), isA<RoundedRectangleBorder>());
          await tester.tap(entry);
        } else {
          final entry = find.text('Second wallet').hitTestable().last;
          final press = await tester.startGesture(tester.getCenter(entry));
          await tester.pump();
          final roundedTint = find.byWidgetPredicate((widget) {
            if (widget is! DecoratedBox) return false;
            final decoration = widget.decoration;
            return decoration is ShapeDecoration &&
                decoration.color == tint &&
                decoration.shape is RoundedRectangleBorder;
          });
          expect(roundedTint, findsOneWidget);
          await press.up();
        }
        await tester.pumpAndSettle();
        expect(selection, 'other');
      },
    );
  }
}
