import 'dart:async';

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/authentification/presentation/models/onboarding_slide.dart';
import 'package:bicount/features/authentification/presentation/widgets/auth_brand_mark.dart';
import 'package:bicount/features/authentification/presentation/widgets/onboarding_background.dart';
import 'package:bicount/features/authentification/presentation/widgets/onboarding_carousel.dart';
import 'package:bicount/features/authentification/presentation/widgets/onboarding_cta_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _autoSlideDelay = Duration(seconds: 6);

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    _scheduleAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : AppColors.tertiaryColorBasic;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: OnboardingBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: BicountReveal(
                      delay: const Duration(milliseconds: 70),
                      child: OnboardingCarousel(
                        controller: _pageController,
                        currentPage: _currentPage,
                        onPageChanged: (value) {
                          setState(() => _currentPage = value);
                          _scheduleAutoSlide();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingLarge),
                  BicountReveal(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      children: [
                        OnboardingCtaRow(
                          onLogIn: () => context.go('/login'),
                          onSignUp: () => context.go('/signUp'),
                        ),
                        const SizedBox(height: AppDimens.spacingMedium),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: Text(
                            key: ValueKey(_currentPage),
                            _footerCopy(context, _currentPage),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: foreground.withValues(alpha: 0.76),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _footerCopy(BuildContext context, int page) {
    switch (page) {
      case 1:
        return context.l10n.onboardingFooterOverview;
      case 2:
        return context.l10n.onboardingFooterPro;
      default:
        return context.l10n.onboardingFooterPrimary;
    }
  }

  void _scheduleAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer(_autoSlideDelay, _advanceSlide);
  }

  void _advanceSlide() {
    if (!mounted || !_pageController.hasClients) {
      return;
    }

    final slideCount = buildOnboardingSlides(context).length;
    if (slideCount <= 1) {
      return;
    }

    final nextPage = (_currentPage + 1) % slideCount;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }
}
