import 'dart:convert';

import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key.endsWith('.svg')) {
        return ByteData.view(
          Uint8List.fromList(
            utf8.encode(
              '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"></svg>',
            ),
          ).buffer,
        );
      }
      return null;
    });
  });

  testWidgets('bottom navigation shows Analysis and hides Company', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: 1,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Company'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('navigation icons and labels share the selection transition', (
    WidgetTester tester,
  ) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: CustomBottomNavigationBar(
              selectedIndex: selectedIndex,
              onTap: (index) => setState(() => selectedIndex = index),
            ),
          ),
        ),
      ),
    );

    SvgPicture icon(String label) => tester
        .widgetList<SvgPicture>(find.byType(SvgPicture))
        .singleWhere((icon) => icon.semanticsLabel == label);
    Color labelColor(String label) =>
        DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

    final inactiveColor = labelColor('Analysis');
    final activeColor = labelColor('Home');
    expect(icon('Analysis').width, 20);
    expect(icon('Home').width, 24);

    await tester.tap(find.text('Analysis'));
    await tester.pump();
    await tester.pump(kThemeAnimationDuration ~/ 2);
    final intermediateColor = labelColor('Analysis');
    expect(intermediateColor, isNot(inactiveColor));
    expect(intermediateColor, isNot(activeColor));
    for (final label in ['Home', 'Analysis']) {
      expect(icon(label).width, inExclusiveRange(20, 24));
      expect(
        icon(label).colorFilter,
        ColorFilter.mode(labelColor(label), BlendMode.srcIn),
      );
    }

    await tester.pumpAndSettle();
    expect(icon('Analysis').width, 24);
    expect(icon('Home').width, 20);
    expect(labelColor('Analysis'), activeColor);
  });
}
