import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    iconTheme: const IconThemeData(color: AppColors.inactiveColorLight),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceColorLight,
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: AppColors.surfaceColorLight),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.grey[300]!; // light grey when pressed
          } else if (states.contains(WidgetState.hovered)) {
            return const Color.fromARGB(255, 208, 208, 208);
          }
          return AppColors.surfaceColorLight;
        }),
        elevation: WidgetStateProperty.resolveWith<double>((states) => 0.0),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(
          AppColors.textColorDark,
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          TextStyle(
            color: AppColors.textColorDark,
            fontSize: AppDimens.textSizeMedium.sp,
          ),
        ),
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
        fontSize: AppDimens.textSizeExtraLarge.sp,
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
    iconTheme: const IconThemeData(color: AppColors.inactiveColorDark),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black, //AppColors.backgroundColorDark,
    ),
    cardColor: AppColors.cardColorDark,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: AppColors.surfaceColorDark),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.grey[800]!; // darker grey when pressed
          } else if (states.contains(WidgetState.hovered)) {
            return Colors.grey[700]!; // dark grey when hovered
          }
          return AppColors.surfaceColorDark;
        }),
        elevation: WidgetStateProperty.resolveWith<double>((states) => 0.0),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(
          AppColors.textColorLight,
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          TextStyle(
            color: AppColors.textColorLight,
            fontSize: AppDimens.textSizeMedium.sp,
          ),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleSmall: TextStyle(
        color: AppColors.secondaryTextColorLight,
        fontSize: AppDimens.textSizeMedium.sp,
      ),
      titleMedium: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeLarge.sp,
      ),
      titleLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeXXLarge.sp,
      ),

      bodySmall: TextStyle(
        color: AppColors.secondaryTextColorLight,
        fontSize: AppDimens.textSizeSmall.sp,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeLarge.sp,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: AppDimens.textSizeMedium.sp,
      ),

      headlineSmall: TextStyle(
        color: AppColors.secondaryTextColorDark,
        fontSize: AppDimens.textSizeSmall.sp,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeExtraLarge.sp,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textColorDark,
        fontSize: AppDimens.textSizeLarge.sp,
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
