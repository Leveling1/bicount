import 'package:flutter/material.dart';

class SmoothInsert extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double verticalMargin;

  const SmoothInsert({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.verticalMargin = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: Alignment.topCenter,
      child: visible
          ? Container(
              margin: EdgeInsets.only(bottom: verticalMargin),
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}
