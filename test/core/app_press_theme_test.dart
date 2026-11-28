import 'dart:ui' as ui;

import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/widgets/navigation_press_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    test('uses one press tint in the ${theme.brightness.name} theme', () {
      const held = {WidgetState.pressed};
      const idle = <WidgetState>{};
      final tint = appPressedColor(theme.primaryColor);

      expect(theme.highlightColor, tint);
      expect(theme.splashFactory, NoSplash.splashFactory);

      for (final style in [
        theme.elevatedButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
        theme.filledButtonTheme.style!,
        theme.textButtonTheme.style!,
        theme.iconButtonTheme.style!,
        theme.menuButtonTheme.style!,
        theme.datePickerTheme.confirmButtonStyle!,
        theme.datePickerTheme.cancelButtonStyle!,
      ]) {
        expect(style.overlayColor!.resolve(held), tint);
        expect(
          style.backgroundColor?.resolve(held),
          style.backgroundColor?.resolve(idle),
        );
        expect(style.splashFactory, NoSplash.splashFactory);
      }

      expect(theme.datePickerTheme.dayOverlayColor!.resolve(held), tint);
      expect(theme.datePickerTheme.yearOverlayColor!.resolve(held), tint);
      expect(theme.checkboxTheme.overlayColor!.resolve(held), tint);
      expect(theme.switchTheme.overlayColor!.resolve(held), tint);
      expect(theme.listTileTheme.shape, isA<RoundedSuperellipseBorder>());

      final walletTheme = AppTheme.walletCorners(theme);
      expect(walletTheme.extension<AppPressFeedback>(), isNull);
      expect(walletTheme.highlightColor, isNot(tint));
      expect(
        walletTheme.elevatedButtonTheme.style!.backgroundColor!.resolve(held),
        isNot(
          walletTheme.elevatedButtonTheme.style!.backgroundColor!.resolve(idle),
        ),
      );
    });
  }

  testWidgets('custom surfaces keep their shape and cancel a press', (
    tester,
  ) async {
    var taps = 0;
    final surfaceKey = GlobalKey();
    final theme = AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS);

    Future<Color> pixelAt(int x, int y) async {
      final boundary =
          surfaceKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final pixels = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final index = (y * image.width + x) * 4;
          return Color.fromARGB(
            pixels.getUint8(index + 3),
            pixels.getUint8(index),
            pixels.getUint8(index + 1),
            pixels.getUint8(index + 2),
          );
        } finally {
          image.dispose();
        }
      }))!;
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Center(
          child: RepaintBoundary(
            key: surfaceKey,
            child: ColoredBox(
              color: Colors.white,
              child: BicountPressable(
                color: Colors.white,
                onTap: () => taps++,
                child: const SizedBox(width: 100, height: 48),
              ),
            ),
          ),
        ),
      ),
    );

    final surface = find.byType(BicountPressable);
    final ink = find.descendant(of: surface, matching: find.byType(InkWell));
    expect(tester.widget<InkWell>(ink).customBorder, appPressShape);
    final gesture = await tester.startGesture(tester.getCenter(ink));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 250));
    expect(taps, 0);
    final pixel = await pixelAt(50, 24);
    final expected = Color.alphaBlend(
      appPressedColor(theme.primaryColor),
      Colors.white,
    );
    expect(pixel.r, closeTo(expected.r, 2 / 255));
    expect(pixel.g, closeTo(expected.g, 2 / 255));
    expect(pixel.b, closeTo(expected.b, 2 / 255));
    expect(await pixelAt(0, 0), Colors.white);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(await pixelAt(50, 24), Colors.white);
    expect(taps, 0);
    await tester.tap(ink);
    expect(taps, 1);
  });

  testWidgets('navigation press stays inside its tab and clears on drag', (
    tester,
  ) async {
    final theme = AppTheme.darkTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Center(
          child: NavigationPressFeedback(
            itemCount: 4,
            child: SizedBox(width: 360, height: 56),
          ),
        ),
      ),
    );
    final navigation = find.byType(NavigationPressFeedback);
    final bounds = tester.getRect(navigation);
    final gesture = await tester.startGesture(
      bounds.topLeft + const Offset(120, 25),
    );
    await tester.pump();
    final highlight = find.descendant(
      of: navigation,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration ==
                ShapeDecoration(
                  color: appPressedColor(theme.primaryColor),
                  shape: appPressShape,
                ),
      ),
    );
    expect(highlight, findsOneWidget);
    final target = tester.getRect(highlight);
    expect(target.left, greaterThan(bounds.left + 90));
    expect(target.right, lessThan(bounds.left + 180));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    expect(highlight, findsNothing);
    await gesture.up();
  });
}
