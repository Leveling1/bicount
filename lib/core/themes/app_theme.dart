import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    cardColor: AppColors.cardColorLight,
    textTheme: const TextTheme(
      titleSmall: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeMedium,
      ),
      titleLarge: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeLarge,
      ),
      
      bodyLarge: TextStyle(color: AppColors.textColorLight),
      bodyMedium: TextStyle(color: AppColors.secondaryTextColorLight),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColorLight,
      surface: AppColors.backgroundColorLight,
      error: AppColors.negativeColorLight,
      secondary: AppColors.positiveColorLight,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    cardColor: AppColors.cardColorDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorDark),
      bodyMedium: TextStyle(color: AppColors.secondaryTextColorDark),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      surface: AppColors.backgroundColorDark,
      error: AppColors.negativeColorDark,
      secondary: AppColors.positiveColorDark,
    ),
  );
}
