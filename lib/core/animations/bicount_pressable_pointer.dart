part of 'bicount_pressable.dart';

extension on _BicountPressableState {
  Widget _observePointer(Widget child) => Listener(
    onPointerDown: _pointerDown,
    onPointerMove: (event) {
      if ((event.position - _origin).distance > kTouchSlop) {
        _pointerEnd(event, cancelled: true);
      }
    },
    onPointerUp: _pointerEnd,
    onPointerCancel: (event) => _pointerEnd(event, cancelled: true),
    child: child,
  );

  void _pointerDown(PointerDownEvent event) {
    if (!widget.enabled ||
        _pointer != null ||
        (event.buttons & kPrimaryButton) == 0) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.position;
    _states.update(WidgetState.pressed, true);
  }

  void _pointerEnd(PointerEvent event, {bool cancelled = false}) {
    if (_pointer != event.pointer) return;
    _pointer = null;
    if (cancelled || MediaQuery.disableAnimationsOf(context)) _cancelHold();
    _states.update(WidgetState.pressed, false);
  }
}
