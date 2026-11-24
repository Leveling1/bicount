import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class DropdownChevronTheme extends ThemeExtension<DropdownChevronTheme> {
  const DropdownChevronTheme({
    this.collapsedIcon = Icons.expand_more,
    this.expandedIcon = Icons.expand_less,
    this.size = 18,
  });

  final IconData collapsedIcon;
  final IconData expandedIcon;
  final double size;

  static const defaults = DropdownChevronTheme();

  static DropdownChevronTheme of(BuildContext context) =>
      Theme.of(context).extension<DropdownChevronTheme>() ?? defaults;

  Icon icon({bool expanded = false, Color? color}) =>
      Icon(expanded ? expandedIcon : collapsedIcon, size: size, color: color);

  @override
  DropdownChevronTheme copyWith({
    IconData? collapsedIcon,
    IconData? expandedIcon,
    double? size,
  }) => DropdownChevronTheme(
    collapsedIcon: collapsedIcon ?? this.collapsedIcon,
    expandedIcon: expandedIcon ?? this.expandedIcon,
    size: size ?? this.size,
  );

  @override
  DropdownChevronTheme lerp(DropdownChevronTheme? other, double t) {
    if (other == null) return this;
    return DropdownChevronTheme(
      collapsedIcon: t < .5 ? collapsedIcon : other.collapsedIcon,
      expandedIcon: t < .5 ? expandedIcon : other.expandedIcon,
      size: lerpDouble(size, other.size, t)!,
    );
  }
}
