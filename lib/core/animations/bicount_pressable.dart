import 'dart:async';

import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'bicount_pressable_pointer.dart';

/// Applies press feedback to an entire surface without changing its hit area.
class BicountPressable extends StatefulWidget {
  const BicountPressable({
    super.key,
    required this.onTap,
    required Widget this.child,
    this.customBorder,
    this.borderRadius = BorderRadius.zero,
    this.color = Colors.transparent,
    this.hoverColor,
    this.clipBehavior = Clip.none,
  }) : builder = null,
       controlBuilder = null,
       isControl = false,
       enabled = true;

  /// Pass the controller to the Material button's `statesController`.
  const BicountPressable.button({super.key, required this.builder})
    : onTap = null,
      child = null,
      customBorder = null,
      borderRadius = BorderRadius.zero,
      color = Colors.transparent,
      hoverColor = null,
      clipBehavior = Clip.none,
      controlBuilder = null,
      isControl = false,
      enabled = true;

  /// Observes pointer presses while the wrapped control handles its own input.
  const BicountPressable.control({
    super.key,
    this.child,
    this.controlBuilder,
    this.enabled = true,
  }) : assert((child == null) != (controlBuilder == null)),
       onTap = null,
       builder = null,
       customBorder = null,
       borderRadius = BorderRadius.zero,
       color = Colors.transparent,
       hoverColor = null,
       clipBehavior = Clip.none,
       isControl = true;

  final VoidCallback? onTap;
  final Widget? child;
  final Widget Function(WidgetStatesController? statesController)? builder;
  final ShapeBorder? customBorder;
  final BorderRadius borderRadius;
  final Color color;
  final Color? hoverColor;
  final Clip clipBehavior;
  final Widget Function(BuildContext context, bool pressed)? controlBuilder;
  final bool enabled;
  final bool isControl;

  @override
  State<BicountPressable> createState() => _BicountPressableState();
}

class _BicountPressableState extends State<BicountPressable> {
  static const _minimumPress = Duration(milliseconds: 64);
  static const _pressDuration = Duration(milliseconds: 55);
  static const _releaseDuration = Duration(milliseconds: 140);

  late final _states = WidgetStatesController()..addListener(_onStateChanged);
  final _showPress = ValueNotifier(false);
  Timer? _hold;
  bool _wasDown = false;
  int? _pointer;
  Offset _origin = Offset.zero;

  void _onStateChanged() {
    final disabled = _states.value.contains(WidgetState.disabled);
    final down = !disabled && _states.value.contains(WidgetState.pressed);
    if (disabled) _cancelHold();
    if (down && !_wasDown) {
      _cancelHold();
      _hold = Timer(_minimumPress, () {
        _hold = null;
        _onStateChanged();
      });
    }
    _wasDown = down;

    final pressed = !disabled && (down || _hold != null);
    if (_showPress.value == pressed) return;
    // Material can reset its controller while rebuilding a disabled control.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onStateChanged();
      });
      return;
    }
    _showPress.value = pressed;
  }

  void _cancelHold() {
    _hold?.cancel();
    _hold = null;
  }

  @override
  void didUpdateWidget(covariant BicountPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _pointer = null;
      _cancelHold();
      _states.update(WidgetState.pressed, false);
      _onStateChanged();
    }
  }

  @override
  void dispose() {
    _cancelHold();
    _states.dispose();
    _showPress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final legacy = WalletCorners.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final button = widget.builder;
    final tint = appPressedColor(Theme.of(context).primaryColor);
    final shape =
        widget.customBorder ??
        (widget.borderRadius == BorderRadius.zero
            ? appPressShape
            : appCornerShape(
                borderRadius: widget.borderRadius,
                legacy: legacy,
              ));
    final surface = button == null && !widget.isControl;
    final tintShape = shape is OutlinedBorder
        ? shape.copyWith(side: BorderSide.none)
        : shape;
    final animate = surface || !reduceMotion;
    final controller = animate ? _states : null;
    final content = widget.isControl
        ? widget.child
        : button?.call(controller) ??
              Material(
                type: widget.color == Colors.transparent
                    ? MaterialType.transparency
                    : MaterialType.canvas,
                color: widget.color,
                shape: shape,
                clipBehavior: widget.clipBehavior,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapCancel: animate ? _cancelHold : null,
                  statesController: controller,
                  customBorder: shape,
                  hoverColor: widget.hoverColor,
                  splashFactory: !legacy ? NoSplash.splashFactory : null,
                  overlayColor: !legacy
                      ? const WidgetStateProperty.fromMap({
                          WidgetState.pressed: Colors.transparent,
                        })
                      : null,
                  child: widget.child,
                ),
              );

    final feedback = ValueListenableBuilder(
      valueListenable: _showPress,
      child: content,
      builder: (context, pressed, child) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: pressed ? 1 : 0),
        duration: reduceMotion
            ? Duration.zero
            : pressed
            ? _pressDuration
            : _releaseDuration,
        curve: Curves.easeOutCubic,
        child:
            widget.controlBuilder?.call(context, widget.enabled && pressed) ??
            child,
        builder: (context, progress, child) => Transform.scale(
          scale: reduceMotion ? 1 : 1 - 0.03 * progress,
          transformHitTests: false,
          child: surface && !legacy
              ? DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: ShapeDecoration(
                    color: tint.withValues(alpha: tint.a * progress),
                    shape: tintShape,
                  ),
                  child: child,
                )
              : child,
        ),
      ),
    );
    if (!widget.isControl) return feedback;

    return _observePointer(feedback);
  }
}
