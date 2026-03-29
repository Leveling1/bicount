import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/path.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : AppColors.tertiaryColorBasic;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
            isDark ? AssetPaths.appIconDark : AssetPaths.appIconLight,
            width: 100, height: 100
        ),
        Text(
          'Bicount',
          style: theme.textTheme.titleLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
