import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/authentification/presentation/models/onboarding_slide.dart';
import 'package:flutter/material.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.tertiaryColorBasic;
    final bodyColor = titleColor.withValues(alpha: isDark ? 0.8 : 0.84);
    final chipBackground = Colors.white.withValues(alpha: isDark ? 0.1 : 0.22);
    final chipBorder = Colors.white.withValues(alpha: isDark ? 0.14 : 0.34);
    final assetPath = slide.assetPathForBrightness(theme.brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    final scale = Tween(
                      begin: 0.96,
                      end: 1.0,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: scale, child: child),
                    );
                  },
                  child: Image.asset(
                    assetPath,
                    key: ValueKey(assetPath),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: chipBackground,
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(color: chipBorder),
          ),
          child: Text(
            slide.badge,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppDimens.spacingMedium),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            slide.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: bodyColor,
              height: 1.45,
            ),
          ),
        ),
        if (slide.highlight != null) ...[
          const SizedBox(height: AppDimens.spacingMedium),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
              vertical: AppDimens.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.tertiaryColorBasic.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            ),
            child: Text(
              slide.highlight!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
