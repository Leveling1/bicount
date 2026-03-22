import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [Color(0xFF08140B), Color(0xFF102617), Color(0xFF0B2132)]
        : [
            AppColors.primaryColorLight,
            AppColors.secondaryColorBasic,
            const Color(0xFF9FD3FF),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.58, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _GlowOrb(
            alignment: const Alignment(-1.05, -0.92),
            size: 280,
            color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.16),
          ),
          _GlowOrb(
            alignment: const Alignment(1.08, -0.35),
            size: 220,
            color: AppColors.quaternaryColorBasic.withValues(
              alpha: isDark ? 0.18 : 0.16,
            ),
          ),
          _GlowOrb(
            alignment: const Alignment(-0.78, 0.98),
            size: 260,
            color: AppColors.tertiaryColorBasic.withValues(
              alpha: isDark ? 0.24 : 0.12,
            ),
          ),
          _GlowOrb(
            alignment: const Alignment(0.95, 0.92),
            size: 340,
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.12),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, Colors.transparent],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
      ),
    );
  }
}
