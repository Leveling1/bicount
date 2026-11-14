import 'package:bicount/features/transaction/presentation/widgets/transaction_empty_results_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty results stay centered below the filters while scrolling', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    const header = Key('filters');
    const message = Key('empty results');
    const viewport = Key('viewport');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            key: viewport,
            controller: controller,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 280)),
              SliverLayoutBuilder(
                builder: (context, constraints) => SliverMainAxisGroup(
                  slivers: [
                    const PinnedHeaderSliver(
                      child: SizedBox(key: header, height: 52),
                    ),
                    TransactionEmptyResultsSliver(
                      precedingScrollExtent: constraints.precedingScrollExtent,
                      child: const Text('No results', key: message),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(controller.position.maxScrollExtent, 280);
    for (final offset in [0.0, 140.0, 280.0]) {
      controller.jumpTo(offset);
      await tester.pumpAndSettle();
      final filterBottom = tester.getBottomLeft(find.byKey(header)).dy;
      final viewportBounds = tester.getRect(find.byKey(viewport));
      final center = tester.getCenter(find.byKey(message));
      expect(center.dx, viewportBounds.center.dx);
      expect(
        center.dy,
        closeTo((filterBottom + viewportBounds.bottom) / 2, .01),
      );
    }
  });
}
