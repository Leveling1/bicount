import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:flutter/material.dart';

/// Gives the text-field anchor and the open menu one press treatment.
class DropdownFieldPress extends StatelessWidget {
  const DropdownFieldPress({
    super.key,
    this.enabled = true,
    this.fillColor,
    required this.builder,
  });

  final bool enabled;
  final Color? fillColor;
  final Widget Function(BuildContext context, DropdownMenuDecorationBuilder)
  builder;

  @override
  Widget build(BuildContext context) {
    return BicountPressable.control(
      enabled: enabled,
      controlBuilder: (context, pressed) {
        final theme = Theme.of(context);
        final tint = appPressedColor(theme.primaryColor);
        final base =
            fillColor ??
            theme.dropdownMenuTheme.inputDecorationTheme?.fillColor ??
            Colors.transparent;
        final iconStyle = theme.iconButtonTheme.style ?? const ButtonStyle();
        return Theme(
          data: theme.copyWith(
            menuButtonTheme: MenuButtonThemeData(
              style: dropdownItemPressStyle(theme),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: iconStyle.copyWith(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    // The field's fill already covers the chevron on touch.
                    return pressed ? Colors.transparent : tint;
                  }
                  return iconStyle.overlayColor?.resolve(states);
                }),
              ),
            ),
          ),
          child: Builder(
            builder: (context) => builder(
              context,
              (context, menuController) => pressed
                  ? InputDecoration(
                      filled: true,
                      fillColor: Color.alphaBlend(tint, base),
                    )
                  : const InputDecoration(),
            ),
          ),
        );
      },
    );
  }
}
