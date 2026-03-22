import 'package:flutter/material.dart';

class MainShellFab extends StatelessWidget {
  const MainShellFab({
    super.key,
    required this.selectedIndex,
    required this.onPressed,
  });

  final int selectedIndex;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: selectedIndex == 2
          ? FloatingActionButton(
              key: const ValueKey('fab'),
              onPressed: onPressed,
              child: Icon(
                Icons.add,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            )
          : const SizedBox.shrink(key: ValueKey('sizedBox')),
    );
  }
}
