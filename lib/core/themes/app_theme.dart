import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    iconTheme: const IconThemeData(
      color: AppColors.inactiveColorLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceColorLight,
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black)),
      ),
    ),
    cardColor: AppColors.cardColorLight,
    textTheme: TextTheme(
      titleSmall: TextStyle(
        color: AppColors.secondaryTextColorLight,
        fontSize: AppDimens.textSizeMedium.sp,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeLarge.sp,
      ),
      titleLarge: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeXXLarge.sp,
        fontWeight: FontWeight.bold,
      ),

      bodySmall: TextStyle(
        color: AppColors.secondaryTextColorLight,
        fontSize: AppDimens.textSizeSmall.sp,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeMedium.sp,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeLarge.sp,
      ),

      headlineSmall: TextStyle(
        color: AppColors.secondaryTextColorLight,
        fontSize: AppDimens.textSizeSmall.sp,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeLarge.sp,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textColorLight,
        fontSize: AppDimens.textSizeXXLarge.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColorLight,

      surface: AppColors.surfaceColorLight,
      error: AppColors.negativeColorLight,
      secondary: AppColors.positiveColorLight,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    iconTheme: const IconThemeData(
      color: AppColors.inactiveColorDark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,//AppColors.backgroundColorDark,
    ),
    cardColor: AppColors.cardColorDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorDark),
      bodyMedium: TextStyle(color: AppColors.secondaryTextColorDark),
      titleSmall: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeMedium,
      ),
      titleLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeLarge,
      ),
      headlineSmall: TextStyle(
        color: AppColors.secondaryTextColorDark,
        fontSize: AppDimens.textSizeSmall,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeExtraLarge,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeLarge,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      surface: AppColors.surfaceColorDark,
      error: AppColors.negativeColorDark,
      secondary: AppColors.positiveColorDark,
    ),
  );
}
