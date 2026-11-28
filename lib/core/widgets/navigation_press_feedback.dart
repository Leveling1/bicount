import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Adds a bounded press tint behind the stock bottom navigation items.
class NavigationPressFeedback extends StatefulWidget {
  const NavigationPressFeedback({
    super.key,
    required this.itemCount,
    required this.child,
  });

  final int itemCount;
  final Widget child;

  @override
  State<NavigationPressFeedback> createState() =>
      _NavigationPressFeedbackState();
}

class _NavigationPressFeedbackState extends State<NavigationPressFeedback> {
  int? _pointer;
  int? _slot;
  Offset _origin = Offset.zero;

  void _start(PointerDownEvent event) {
    final width = context.size!.width;
    if (_pointer != null || width <= 0 || event.buttons != kPrimaryButton) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.localPosition;
    setState(() {
      _slot = (_origin.dx * widget.itemCount / width).floor().clamp(
        0,
        widget.itemCount - 1,
      );
    });
  }

  void _end(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    setState(() => _slot = null);
  }

  @override
  Widget build(BuildContext context) {
    final slot = _slot;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _start,
      onPointerMove: (event) {
        if ((event.localPosition - _origin).distance > kTouchSlop) _end(event);
      },
      onPointerUp: _end,
      onPointerCancel: _end,
      child: Stack(
        children: [
          if (slot != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    for (var index = 0; index < widget.itemCount; index++)
                      Expanded(
                        child: index == slot
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.paddingExtraSmall,
                                ),
                                child: DecoratedBox(
                                  decoration: ShapeDecoration(
                                    color: appPressedColor(
                                      Theme.of(context).primaryColor,
                                    ),
                                    shape: appPressShape,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}
