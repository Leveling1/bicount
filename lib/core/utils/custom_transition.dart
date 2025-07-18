import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<void> buildCustomTransitionPage({
  required childContain,
  required GoRouterState state,
  required dynamic model,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: childContain,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

