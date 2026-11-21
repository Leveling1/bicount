import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/features/home/presentation/widgets/home_header_sliver_layout.dart';
import 'package:bicount/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the loading header lays out at startup and while collapsing', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 700.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: 560,
                child: const HomeLoadingSkeleton(),
              ),
            ),
          ),
        ),
      );
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      scroll.position.jumpTo(0);
      await tester.pump();
      expect(tester.takeException(), isNull);
      final viewport = tester.getRect(find.byType(CustomScrollView));
      final actions = tester.getRect(
        find.byKey(const ValueKey('home-loading-actions')),
      );
      final header = tester.renderObject<RenderSliver>(
        find.byType(HomeHeaderSliverLayout),
      );
      expect(
        actions.top - viewport.top - header.geometry!.scrollExtent,
        closeTo(16, .01),
      );
      if (BackendEnvironment.isLocalPreproduction) {
        final preview = tester.getRect(
          find.byKey(const ValueKey('home-wallet-skeleton')),
        );
        expect(preview.right, viewport.right);
        expect(actions.top - preview.bottom, closeTo(16, .01));
      }

      for (final offset in [20.0, 100.0, 120.0, 250.0, 0.0]) {
        scroll.position.jumpTo(offset);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'scroll offset $offset');
      }
    }
  });
}
