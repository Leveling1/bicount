import 'package:flutter/material.dart';

class TransactionEmptyResultsSliver extends StatelessWidget {
  const TransactionEmptyResultsSliver({
    super.key,
    required this.precedingScrollExtent,
    required this.child,
  });

  final double precedingScrollExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final headerExtent =
            constraints.precedingScrollExtent - precedingScrollExtent;
        // Keep a full viewport after the wallet cards so they can scroll away.
        final extent = (constraints.viewportMainAxisExtent - headerExtent)
            .clamp(0.0, constraints.viewportMainAxisExtent);
        final visibleEnd =
            (constraints.scrollOffset + constraints.remainingPaintExtent).clamp(
              0.0,
              extent,
            );
        final visibleStart = (constraints.scrollOffset + constraints.overlap)
            .clamp(0.0, visibleEnd);

        return SliverToBoxAdapter(
          child: SizedBox(
            height: extent,
            child: Padding(
              padding: EdgeInsets.only(
                top: visibleStart,
                bottom: extent - visibleEnd,
              ),
              child: ClipRect(
                child: OverflowBox(
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
