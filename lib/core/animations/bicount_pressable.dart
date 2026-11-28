import 'dart:async';

import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'bicount_pressable_pointer.dart';
part 'bicount_pressable_feedback.dart';

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
    this.scaleContentOnly = false,
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
      scaleContentOnly = false,
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
       scaleContentOnly = false,
       isControl = true;

  final VoidCallback? onTap;
  final Widget? child;
  final Widget Function(WidgetStatesController? statesController)? builder;
  final ShapeBorder? customBorder;
  final BorderRadius borderRadius;
  final Color color;
  final Color? hoverColor;
  final Clip clipBehavior;

  /// Keeps the hit area and tint still while scaling the contents on press.
  final bool scaleContentOnly;

  final Widget Function(BuildContext context, bool pressed)? controlBuilder;
  final bool enabled;
  final bool isControl;

  @override
  State<BicountPressable> createState() => _BicountPressableState();
}

class _BicountPressableState extends State<BicountPressable> {
  static const _minimumPress = Duration(milliseconds: 64);

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
  Widget build(BuildContext context) => _buildFeedback(context);
}
