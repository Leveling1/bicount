import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/icon_links.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimens.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.loading,
  });

  final VoidCallback onPressed;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.dp50,
      child: BicountPressable.button(
        builder: (statesController) => ElevatedButton(
          statesController: statesController,
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
                    height: AppSizes.dp32,
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: Theme.of(context).cardColor,
                      size: AppSizes.dp38,
                    ),
                  )
                : Text(text, key: ValueKey(text)),
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.loading,
  });

  final VoidCallback onPressed;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.dp50,
      child: BicountPressable.button(
        builder: (statesController) => OutlinedButton(
          statesController: statesController,
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
                    height: AppSizes.dp32,
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: Theme.of(context).cardColor,
                      size: AppSizes.dp38,
                    ),
                  )
                : Text(text, key: ValueKey(text), textAlign: TextAlign.center),
          ),
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
      child: BicountPressable.button(
        builder: (statesController) => ElevatedButton(
          statesController: statesController,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.dp20,
                vertical: AppSizes.dp11,
              ),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('provider_loading'),
                      height: AppSizes.dp32,
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: Theme.of(context).cardColor,
                        size: AppSizes.dp38,
                      ),
                    )
                  : Row(
                      key: const ValueKey('provider_content'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppSizes.dp36,
                          height: AppSizes.dp36,
                          decoration: appCornerDecoration(
                            color: AppColors.surfaceColorDark,
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadiusMedium,
                            ),
                            legacy: WalletCorners.of(context),
                          ),
                          padding: const EdgeInsets.all(AppDimens.paddingSmall),
                          child: SvgPicture.asset(icon),
                        ),
                        AppDimens.spacerWidthMedium,
                        Flexible(
                          child: Text(label, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
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
  const CustomAuthIconButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(
      context,
    ).elevatedButtonTheme.style?.backgroundColor?.resolve({});
    return Container(
      width: AppSizes.dp36,
      height: AppSizes.dp36,
      margin: EdgeInsets.only(
        right: AppDimens.marginExtraSmall,
        top: AppDimens.marginExtraSmall,
        bottom: AppDimens.marginExtraSmall,
      ),
      child: BicountPressable(
        color: background ?? Colors.transparent,
        hoverColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor
            ?.resolve({})
            ?.withValues(alpha: 0.4),
        customBorder: appCornerShape(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          legacy: WalletCorners.of(context),
        ),
        onTap: loading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingSmall),
          child: loading
              ? LoadingAnimationWidget.hexagonDots(
                  color: Theme.of(context).cardColor,
                  size: AppSizes.dp15,
                )
              : Icon(Icons.arrow_forward, color: Theme.of(context).cardColor),
        ),
      ),
    );
  }
}

class CustomButtonWithIcon extends StatelessWidget {
  const CustomButtonWithIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final bool loading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.dp50,
      child: BicountPressable.button(
        builder: (statesController) => ElevatedButton(
          statesController: statesController,
          onPressed: loading ? null : onPressed,
          /*style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),*/
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
                    height: AppSizes.dp32,
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: Theme.of(context).cardColor,
                      size: AppSizes.dp38,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      AppDimens.spacerWidthMedium,
                      Text(text, key: ValueKey(text)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.loading = false,
    required this.onPressed,
    required this.icon,
    this.color,
  });

  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.dp36,
      height: AppSizes.dp36,
      margin: EdgeInsets.only(
        right: AppDimens.marginExtraSmall,
        top: AppDimens.marginExtraSmall,
        bottom: AppDimens.marginExtraSmall,
      ),
      child: BicountPressable(
        color: Theme.of(context).cardColor,
        hoverColor: Theme.of(context).cardColor.withValues(alpha: 0.4),
        customBorder: appCornerShape(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          legacy: WalletCorners.of(context),
        ),
        onTap: loading ? null : onPressed,
        child: Center(
          child: loading
              ? LoadingAnimationWidget.hexagonDots(
                  color:
                      color ??
                      Theme.of(context)
                          .elevatedButtonTheme
                          .style!
                          .backgroundColor!
                          .resolve({})!,
                  size: AppSizes.dp15,
                )
              : Icon(
                  icon,
                  color:
                      color ??
                      Theme.of(
                        context,
                      ).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                ),
        ),
      ),
    );
  }
}
