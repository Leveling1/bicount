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

class CustomOutlinedButton extends StatelessWidget {
  CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
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
      child: OutlinedButton(
        onPressed: onPressed,
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
              : Text(text, key: ValueKey(text), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// Provider button for Google and Apple.
enum AuthProviderType { google, apple }

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
    required this.provider,
    required this.icon,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final String icon;
  final AuthProviderType provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('provider_loading'),
                    height: 32,
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: Theme.of(context).cardColor,
                      size: 38,
                    ),
                  )
                : Row(
                    key: const ValueKey('provider_content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColorDark,
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadiusMedium,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(icon),
                      ),
                      AppDimens.spacerWidthMedium,
                      Flexible(child: Text(label, textAlign: TextAlign.center)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class CustomGoogleAuthButton extends StatelessWidget {
  const CustomGoogleAuthButton({
    super.key,
    this.isLoading = false,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _ProviderButton(
      isLoading: isLoading,
      onPressed: onPressed,
      label: context.l10n.authContinueWithGoogle,
      icon: IconLinks.googleIcon,
      provider: AuthProviderType.google,
    );
  }
}

class CustomAppleAuthButton extends StatelessWidget {
  const CustomAppleAuthButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _ProviderButton(
      isLoading: isLoading,
      onPressed: onPressed,
      label: context.l10n.authContinueWithApple,
      icon: IconLinks.appleIcon,
      provider: AuthProviderType.apple,
    );
  }
}

class CustomAuthIconButton extends StatelessWidget {
  const CustomAuthIconButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
      ),
      margin: EdgeInsets.only(
        right: AppDimens.marginExtraSmall,
        top: AppDimens.marginExtraSmall,
        bottom: AppDimens.marginExtraSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context)
              .elevatedButtonTheme
              .style
              ?.backgroundColor
              ?.resolve({})
              ?.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_forward,
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
      ),
    );
  }
}
