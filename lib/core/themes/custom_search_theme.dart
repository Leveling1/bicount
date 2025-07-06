import 'package:flutter/material.dart';

class CustomSearchTheme {
  static InputDecorationTheme inputDecorationTheme(BuildContext context) {
    return InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      prefixIconColor: Theme.of(context).colorScheme.primary,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    );
  }

  static ThemeData theme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: inputDecorationTheme(context),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}