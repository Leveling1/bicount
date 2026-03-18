import 'dart:convert';
import 'dart:typed_data';

import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('bottom navigation shows Graphs and hides Company', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: 1,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Graphs'), findsOneWidget);
    expect(find.text('Company'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
