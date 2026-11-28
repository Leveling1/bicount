import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

/// Marks the theme that uses Bicount's uniform background press feedback.
class AppPressFeedback extends ThemeExtension<AppPressFeedback> {
  const AppPressFeedback({
    required this.originalHighlight,
    required this.originalSplash,
  });

  final Color originalHighlight;
  final InteractiveInkFeatureFactory originalSplash;

  static bool of(BuildContext context) =>
      Theme.of(context).extension<AppPressFeedback>() != null;

  @override
  AppPressFeedback copyWith() => this;

  @override
  AppPressFeedback lerp(AppPressFeedback? other, double t) {
    if (other == null) return this;
    return AppPressFeedback(
      originalHighlight: Color.lerp(
        originalHighlight,
        other.originalHighlight,
        t,
      )!,
      originalSplash: t < 0.5 ? originalSplash : other.originalSplash,
    );
  }
}

Color appPressedColor(Color primary) => primary.withValues(alpha: 0.16);

const appPressShape = RoundedSuperellipseBorder(
  borderRadius: BorderRadius.all(Radius.circular(AppDimens.borderRadiusMedium)),
);

ButtonStyle dropdownItemPressStyle(ThemeData theme) {
  final style = theme.menuButtonTheme.style ?? const ButtonStyle();
  final onSurface = theme.colorScheme.onSurface;
  final legacy = theme.extension<WalletCorners>() != null;
  return style.copyWith(
    splashFactory: NoSplash.splashFactory,
    shape:
        style.shape ??
        WidgetStatePropertyAll(
          legacy
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimens.borderRadiusMedium),
                  ),
                )
              : appPressShape,
        ),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return Colors.transparent;
      if (states.contains(WidgetState.pressed)) {
        return appPressedColor(theme.primaryColor);
      }
      return style.overlayColor?.resolve(states) ??
          onSurface.withValues(
            alpha: states.contains(WidgetState.focused)
                ? .10
                : states.contains(WidgetState.hovered)
                ? .08
                : 0,
          );
    }),
  );
}

ThemeData withAppPressFeedback(ThemeData theme) {
  final pressed = appPressedColor(theme.primaryColor);

  WidgetStateProperty<Color?> pressOverlay([
    WidgetStateProperty<Color?>? previous,
  ]) {
    return WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.pressed) &&
              !states.contains(WidgetState.disabled)
          ? pressed
          : previous?.resolve(states),
    );
  }

  ButtonStyle button(ButtonStyle? previous, {bool keepShape = false}) {
    final style = previous ?? const ButtonStyle();
    final background = style.backgroundColor;
    return style.copyWith(
      splashFactory: NoSplash.splashFactory,
      overlayColor: pressOverlay(style.overlayColor),
      backgroundColor: background == null
          ? null
          : WidgetStateProperty.resolveWith(
              (states) => background.resolve(
                states.contains(WidgetState.pressed)
                    ? states.difference({
                        WidgetState.pressed,
                        WidgetState.hovered,
                      })
                    : states,
              ),
            ),
      shape: keepShape
          ? style.shape
          : style.shape ?? const WidgetStatePropertyAll(appPressShape),
    );
  }

  final dates = theme.datePickerTheme;
  return theme.copyWith(
    extensions: [
      ...theme.extensions.values,
      AppPressFeedback(
        originalHighlight: theme.highlightColor,
        originalSplash: theme.splashFactory,
      ),
    ],
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: pressed,
    floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
      splashColor: Colors.transparent,
      highlightElevation: theme.floatingActionButtonTheme.elevation ?? 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: button(theme.elevatedButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: button(theme.outlinedButtonTheme.style),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: button(theme.filledButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: button(theme.textButtonTheme.style),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: button(theme.iconButtonTheme.style, keepShape: true),
    ),
    menuButtonTheme: MenuButtonThemeData(style: dropdownItemPressStyle(theme)),
    listTileTheme: theme.listTileTheme.copyWith(
      shape: theme.listTileTheme.shape ?? appPressShape,
    ),
    checkboxTheme: theme.checkboxTheme.copyWith(
      overlayColor: pressOverlay(theme.checkboxTheme.overlayColor),
    ),
    switchTheme: theme.switchTheme.copyWith(
      overlayColor: pressOverlay(theme.switchTheme.overlayColor),
    ),
    datePickerTheme: dates.copyWith(
      dayOverlayColor: pressOverlay(dates.dayOverlayColor),
      yearOverlayColor: pressOverlay(dates.yearOverlayColor),
      confirmButtonStyle: button(dates.confirmButtonStyle),
      cancelButtonStyle: button(dates.cancelButtonStyle),
    ),
  );
}
