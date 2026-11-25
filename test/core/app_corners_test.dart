import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/wallet_corner_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    testWidgets(
      'wallet overlays preserve corners in ${theme.brightness.name}',
      (tester) async {
        final modalTitle = ValueKey(theme.brightness);
        Widget opener(String label) => Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCustomBottomSheet<void>(
              context: context,
              minHeight: 0,
              child: TextField(
                key: modalTitle,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ),
            child: Text(label),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  opener('App'),
                  WalletCornerTheme(child: opener('Wallet')),
                ],
              ),
            ),
          ),
        );

        final appButton = tester.element(find.text('App'));
        final walletButton = tester.element(find.text('Wallet'));
        expect(
          Theme.of(appButton).elevatedButtonTheme.style?.shape?.resolve({}),
          isA<RoundedSuperellipseBorder>(),
        );
        expect(
          Theme.of(walletButton).elevatedButtonTheme.style?.shape?.resolve({}),
          isA<RoundedRectangleBorder>(),
        );

        await tester.tap(find.text('App'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<BottomSheet>(find.byType(BottomSheet)).shape,
          isA<RoundedSuperellipseBorder>(),
        );
        expect(
          Theme.of(
            tester.element(find.byKey(modalTitle)),
          ).inputDecorationTheme.border,
          isA<ShapedInputBorder>(),
        );
        Navigator.of(tester.element(find.byKey(modalTitle))).pop();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wallet'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<BottomSheet>(find.byType(BottomSheet)).shape,
          isA<RoundedRectangleBorder>(),
        );
        expect(
          Theme.of(
            tester.element(find.byKey(modalTitle)),
          ).inputDecorationTheme.border,
          isA<OutlineInputBorder>(),
        );
      },
    );
  }
}
