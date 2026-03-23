import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class OnboardingCtaRow extends StatelessWidget {
  const OnboardingCtaRow({
    super.key,
    required this.onLogIn,
    required this.onSignUp,
  });

  final VoidCallback onLogIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onLogIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tertiaryColorBasic,
              backgroundColor:
                  Theme.of(context).elevatedButtonTheme.style?.backgroundColor
                      ?.resolve(const <WidgetState>{})
                      ?.withValues(alpha: 0.2) ??
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.38),
              side: BorderSide(
                color: Theme.of(context)
                    .elevatedButtonTheme
                    .style!
                    .backgroundColor!
                    .resolve(const <WidgetState>{})!,
                width: 1.4,
              ),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusLarge,
                ),
              ),
            ),
            child: Text(
              context.l10n.authLogIn,
              style: TextStyle(
                color: Theme.of(context)
                    .elevatedButtonTheme
                    .style
                    ?.backgroundColor
                    ?.resolve(const <WidgetState>{}),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.spacingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: onSignUp,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusLarge,
                ),
              ),
            ),
            child: Text(context.l10n.authSignUp),
          ),
        ),
      ],
    );
  }
}
