import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS);

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      '${platform.name} buttons compress without delaying their action',
      (tester) async {
        var presses = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.copyWith(platform: platform),
            home: Scaffold(
              body: Center(
                child: CustomButton(
                  text: 'Continue',
                  onPressed: () => presses++,
                  loading: false,
                ),
              ),
            ),
          ),
        );

        final button = find.byType(ElevatedButton);
        final feedback = find.byType(BicountPressable);
        final buttonTheme = Theme.of(
          tester.element(button),
        ).elevatedButtonTheme;
        expect(
          buttonTheme.style?.overlayColor?.resolve({WidgetState.pressed}),
          appPressedColor(theme.primaryColor),
        );
        final bounds = tester.getRect(button);
        await tester.tap(button);
        expect(presses, 1);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 48));

        final transform = find
            .descendant(of: feedback, matching: find.byType(Transform))
            .first;
        expect(
          tester.widget<Transform>(transform).transform.storage[0],
          lessThan(1),
        );
        expect(tester.getSize(button), bounds.size);
        await tester.pumpAndSettle();
        expect(tester.getRect(button), bounds);
      },
    );
  }

  testWidgets('custom surfaces use the theme tint with reduced motion', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(
            child: BicountPressable(
              onTap: () => presses++,
              child: const SizedBox(width: 100, height: 48),
            ),
          ),
        ),
      ),
    );
    final target = find.byType(BicountPressable);
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump(const Duration(milliseconds: 110));

    final transform = find.descendant(
      of: target,
      matching: find.byType(Transform),
    );
    final paint = find.descendant(
      of: target,
      matching: find.byType(DecoratedBox),
    );
    expect(tester.widget<Transform>(transform).transform.storage[0], 1);
    final decoration = tester.widget<DecoratedBox>(paint).decoration;
    expect(
      (decoration as ShapeDecoration).color,
      appPressedColor(theme.primaryColor),
    );
    expect(decoration.shape, appPressShape);

    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(presses, 0);
  });

  testWidgets('bottom navigation keeps its original touch feedback', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: selected,
            onTap: (index) => selected = index,
          ),
        ),
      ),
    );

    final bar = find.byType(BottomNavigationBar);
    final barTheme = Theme.of(tester.element(bar));
    final appFeedback = theme.extension<AppPressFeedback>()!;
    expect(barTheme.highlightColor, appFeedback.originalHighlight);
    expect(barTheme.splashFactory, appFeedback.originalSplash);
    expect(
      find.descendant(of: bar, matching: find.byType(BicountPressable)),
      findsNothing,
    );

    final tiles = find.descendant(of: bar, matching: find.byType(InkResponse));
    await tester.tap(tiles.at(1));
    expect(selected, 1);
  });
}
