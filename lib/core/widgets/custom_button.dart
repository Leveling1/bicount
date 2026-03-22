import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/icon_links.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimens.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.loading,
  });

  final VoidCallback onPressed;
  final WidgetStatesController statesController = WidgetStatesController();
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            final scale = Tween(begin: 0.98, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          child: loading
              ? SizedBox(
                  key: const ValueKey('button_loading'),
                  height: 32,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).cardColor,
                    size: 38,
                  ),
                )
              : Text(text, key: ValueKey(text)),
        ),
      ),
    );
  }
}

class CustomGoogleAuthButton extends StatelessWidget {
  const CustomGoogleAuthButton({
    super.key,
    this.isLogin = false,
    this.isLoading = false,
    required this.onPressed,
  });

  final bool isLogin;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiaryColorBasic,
          backgroundColor: Theme.of(context).textTheme.titleLarge!.color!.withValues(alpha: 0.05),
          side: BorderSide(
            color: Theme.of(context).textTheme.titleLarge!.color!.withValues(alpha: 0.50),
            width: 1.4,
          ),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimens.radiusMedium,
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            final scale = Tween(begin: 0.98, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('google_loading'),
                  height: 32,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).textTheme.titleLarge!.color!,
                    size: 38,
                  ),
                )
              : Row(
                  key: const ValueKey('google_content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusMedium,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(IconLinks.googleIcon),
                    ),
                    AppDimens.spacerWidthMedium,
                    Flexible(
                      child: Text(
                        isLogin
                            ? context.l10n.authContinueWithGoogle
                            : context.l10n.authCreateGoogleAccount,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).textTheme.titleLarge?.color!,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
