import 'dart:math' as math;

import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/authentification/presentation/models/onboarding_slide.dart';
import 'package:bicount/features/authentification/presentation/widgets/onboarding_slide_view.dart';
import 'package:flutter/material.dart';

class OnboardingCarousel extends StatelessWidget {
  const OnboardingCarousel({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slides = buildOnboardingSlides(context);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final pageValue =
                      controller.hasClients &&
                          controller.position.hasContentDimensions
                      ? controller.page ?? currentPage.toDouble()
                      : currentPage.toDouble();
                  final delta = index - pageValue;
                  final scale = (1 - (delta.abs() * 0.08)).clamp(0.9, 1.0);
                  final opacity = (1 - (delta.abs() * 0.28)).clamp(0.62, 1.0);
                  final offsetX = delta * 22;
                  final offsetY = math.min(delta.abs() * 10, 10).toDouble();

                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(offsetX, offsetY),
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: OnboardingSlideView(slide: slides[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimens.spacingLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? Colors.white : AppColors.tertiaryColorBasic)
                    : Colors.white.withValues(alpha: isDark ? 0.32 : 0.52),
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusFull,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
