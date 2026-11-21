import 'package:bicount/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the loading header lays out at startup and while collapsing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 390,
              height: 560,
              child: HomeLoadingSkeleton(),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    for (final offset in [20.0, 100.0, 120.0, 250.0, 0.0]) {
      scroll.position.jumpTo(offset);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'scroll offset $offset');
    }
  });
}
