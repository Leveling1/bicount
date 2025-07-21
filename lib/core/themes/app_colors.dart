import 'package:flutter/material.dart';

class AppColors {
  /// Universal colors
  static const Color primaryColorBasic = Color(0xFF76A646);
  static const Color secondaryColorBasic = Color(0xFFBDF26D);
  static const Color tertiaryColorBasic = Color(0xFF052608);
  static const Color quaternaryColorBasic = Color(0xFF0554F2);
  static const Color backgroundColorBasic = Color(0xFFEFF2EB);

  /// Dark Theme
  static const Color primaryColorDark = Color(0xFF76A646);
  static const Color backgroundColorDark = Color(0xFF1A1A1A);
  static const Color cardColorDark = Color(0xFF2C2C2C);
  static const Color surfaceColorDark = Color(0xFFF9F9F9);
  static const Color textColorDark = Color(0xFFE0E0E0);
  static const Color secondaryTextColorDark = Color(0xFFB0B0B0);
  static const Color positiveColorDark = Color(0xFF4CAF50);
  static const Color negativeColorDark = Color(0xFFF44336);
  static const Color inactiveColorDark = Color(0xFF808080);
  static const LinearGradient cardLinearGradientDark = LinearGradient(
    colors: [Color(0XFF1E2028), Color(0XFF2B2E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  /// Light Theme
  static const Color primaryColorLight = Color(0xFF76A646);
  static const Color backgroundColorLight = Color(0xFFF9F9F9);
  static const Color surfaceColorLight = Color(0xFF2C2C2C);
  static const Color cardColorLight = Color(0xFFE8E8E8);
  static const Color textColorLight = Color(0xFF212121);
  static const Color secondaryTextColorLight = Color(0xFF757575);
  static const Color positiveColorLight = Color(0xFF4CAF50);
  static const Color negativeColorLight = Color(0xFFF44336);
  static const Color inactiveColorLight = Color(0xFFCCCCCC);
  static const LinearGradient cardLinearGradientLight = LinearGradient(
    colors: [Colors.white70, Colors.white30],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
