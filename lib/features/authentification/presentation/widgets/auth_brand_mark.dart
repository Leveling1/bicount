import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/icon_links.dart';

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
        SvgPicture.asset(
          isDark ? IconLinks.appIconDark : IconLinks.appIconLight,
          width: 40,
          height: 40,
        ),
        AppDimens.spacerWidthSmall,
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
