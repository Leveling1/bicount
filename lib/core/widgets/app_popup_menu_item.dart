import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:flutter/material.dart';

class AppPopupMenuItem<T> extends PopupMenuItem<T> {
  const AppPopupMenuItem({
    super.key,
    required super.value,
    required super.child,
    super.enabled,
    this.selected = false,
  });

  final bool selected;

  @override
  PopupMenuItemState<T, AppPopupMenuItem<T>> createState() =>
      _AppPopupMenuItemState<T>();
}

class _AppPopupMenuItemState<T>
    extends PopupMenuItemState<T, AppPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    final item = BicountPressable.control(
      enabled: widget.enabled,
      child: super.build(context),
    );
    if (WalletCorners.of(context)) return item;
    final selected = widget.selected;
    return Material(
      type: selected ? MaterialType.canvas : MaterialType.transparency,
      color: selected
          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
          : Colors.transparent,
      shape: appPressShape,
      clipBehavior: Clip.antiAlias,
      child: selected ? Semantics(selected: true, child: item) : item,
    );
  }
}
