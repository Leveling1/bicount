import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'custom_bottom_navigation_bar.dart';

@Preview(name: 'Bottom navigation selection', size: Size(400, 120))
Widget bottomNavigationPreview() {
  var selectedIndex = 0;
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StatefulBuilder(
      builder: (context, setState) => Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
        ),
      ),
    ),
  );
}
