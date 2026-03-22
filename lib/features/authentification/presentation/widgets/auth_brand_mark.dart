import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : AppColors.tertiaryColorBasic;
    final tileColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.28);

    return Row(
      children: [
        Hero(
          tag: 'bicount_auth_mark',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusLarge,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: foreground,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bicount',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground.withValues(alpha: 0.72),
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
