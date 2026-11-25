import 'package:flutter/material.dart';

/// Keeps the existing corner geometry in wallet controls and their overlays.
class WalletCorners extends ThemeExtension<WalletCorners> {
  const WalletCorners();

  static bool of(BuildContext context) =>
      Theme.of(context).extension<WalletCorners>() != null;

  @override
  WalletCorners copyWith() => this;

  @override
  WalletCorners lerp(WalletCorners? other, double t) => this;
}

OutlinedBorder appCornerShape({
  required BorderRadiusGeometry borderRadius,
  BorderSide side = BorderSide.none,
  bool legacy = false,
}) {
  return legacy
      ? RoundedRectangleBorder(borderRadius: borderRadius, side: side)
      : RoundedSuperellipseBorder(borderRadius: borderRadius, side: side);
}

InputBorder appInputBorder({
  required BorderRadius borderRadius,
  BorderSide borderSide = const BorderSide(),
  bool legacy = false,
}) {
  return legacy
      ? OutlineInputBorder(borderRadius: borderRadius, borderSide: borderSide)
      : ShapedInputBorder(
          shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
          borderSide: borderSide,
        );
}

Decoration appCornerDecoration({
  required BorderRadius borderRadius,
  Color? color,
  bool legacy = false,
}) {
  return legacy
      ? BoxDecoration(color: color, borderRadius: borderRadius)
      : ShapeDecoration(
          color: color,
          shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
        );
}
