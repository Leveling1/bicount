import 'package:flutter/material.dart';

class MainShellFab extends StatelessWidget {
  const MainShellFab({
    super.key,
    required this.selectedIndex,
    required this.onPressed,
    required this.transaction,
  });

  final int selectedIndex;
  final VoidCallback onPressed;
  final int transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: selectedIndex == 2 && transaction != 0
            ? FloatingActionButton(
                key: const ValueKey('fab'),
                onPressed: onPressed,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              )
            : const SizedBox.shrink(key: ValueKey('sizedBox')),
      ),
    );
  }
}
