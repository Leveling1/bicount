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
  });

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
    return Material(
      type: MaterialType.transparency,
      shape: appPressShape,
      clipBehavior: Clip.antiAlias,
      child: item,
    );
  }
}
