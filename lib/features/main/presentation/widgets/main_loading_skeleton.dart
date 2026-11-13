import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:bicount/features/home/presentation/widgets/home_loading_skeleton.dart';

class MainLoadingSkeleton extends StatelessWidget {
  const MainLoadingSkeleton({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => switch (index) {
    1 => const _AnalysisPlaceholder(),
    2 => const _TransactionPlaceholder(),
    3 => const _ProfilePlaceholder(),
    _ => const HomeLoadingSkeleton(),
  };
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
    children: const [
      SizedBox(height: 28),
      Center(child: BicountSkeletonCircle(size: 96)),
      SizedBox(height: 20),
      Center(child: BicountSkeletonBox(width: 180, height: 24)),
      SizedBox(height: 10),
      Center(child: BicountSkeletonBox(width: 220, height: 16)),
      SizedBox(height: 28),
      _TwoCards(height: 138),
      SizedBox(height: 16),
      _TwoCards(height: 138),
      SizedBox(height: 24),
      _SectionTitle(),
      SizedBox(height: 12),
      _ContactRows(),
    ],
  );
}

class _TransactionPlaceholder extends StatelessWidget {
  const _TransactionPlaceholder();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
    children: const [SizedBox(height: 20), _TransactionRows()],
  );
}

class _AnalysisPlaceholder extends StatelessWidget {
  const _AnalysisPlaceholder();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppDimens.paddingMedium),
    children: const [
      BicountSkeletonBox(width: 160, height: 22),
      SizedBox(height: 14),
      BicountSkeletonBox(height: 44),
      SizedBox(height: 16),
      _TwoCards(height: 100),
      SizedBox(height: 16),
      BicountSkeletonBox(height: 220),
      SizedBox(height: 16),
      BicountSkeletonBox(height: 200),
    ],
  );
}

class _TwoCards extends StatelessWidget {
  const _TwoCards({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: BicountSkeletonBox(height: height)),
      const SizedBox(width: AppDimens.marginMedium),
      Expanded(child: BicountSkeletonBox(height: height)),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      BicountSkeletonBox(width: 140, height: 22),
      BicountSkeletonBox(width: 72, height: 18),
    ],
  );
}

class _TransactionRows extends StatelessWidget {
  const _TransactionRows();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      5,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: AppDimens.spacingSmall),
        child: BicountSkeletonBox(height: 76),
      ),
    ),
  );
}

class _ContactRows extends StatelessWidget {
  const _ContactRows();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: AppDimens.spacingSmall),
        child: BicountSkeletonBox(height: 80),
      ),
    ),
  );
}
