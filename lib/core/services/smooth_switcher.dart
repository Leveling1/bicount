import 'package:flutter/material.dart';

class SmoothSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SmoothSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final sizeAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: sizeAnim,
              axisAlignment: -1,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(sizeAnim),
                child: child,
              ),
            ),
          );
        },
        child: child,
      ),
    );
  }
}
