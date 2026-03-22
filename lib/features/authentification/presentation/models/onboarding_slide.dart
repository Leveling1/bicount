import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.lightAssetPath,
    required this.darkAssetPath,
    required this.badge,
    required this.title,
    required this.description,
    this.highlight,
  });

  final String lightAssetPath;
  final String darkAssetPath;
  final String badge;
  final String title;
  final String description;
  final String? highlight;

  String assetPathForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkAssetPath : lightAssetPath;
  }
}

List<OnboardingSlide> buildOnboardingSlides(BuildContext context) {
  final l10n = context.l10n;
  return [
    OnboardingSlide(
      lightAssetPath: 'assets/images/onboarding_shared_money_light.png',
      darkAssetPath: 'assets/images/onboarding_shared_money_dark.png',
      badge: l10n.onboardingSharedMoneyBadge,
      title: l10n.onboardingSharedMoneyTitle,
      description: l10n.onboardingSharedMoneyDescription,
    ),
    OnboardingSlide(
      lightAssetPath: 'assets/images/onboarding_insights_light.png',
      darkAssetPath: 'assets/images/onboarding_insights_dark.png',
      badge: l10n.onboardingDailyOverviewBadge,
      title: l10n.onboardingDailyOverviewTitle,
      description: l10n.onboardingDailyOverviewDescription,
    ),
    OnboardingSlide(
      lightAssetPath: 'assets/images/onboarding_bicount_pro_light.png',
      darkAssetPath: 'assets/images/onboarding_bicount_pro_dark.png',
      badge: l10n.onboardingProBadge,
      title: l10n.onboardingProTitle,
      description: l10n.onboardingProDescription,
      highlight: l10n.onboardingProHighlight,
    ),
  ];
}
