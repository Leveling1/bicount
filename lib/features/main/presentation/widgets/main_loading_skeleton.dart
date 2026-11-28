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
      SizedBox(height: AppSizes.dp28),
      Center(child: BicountSkeletonCircle(size: AppSizes.dp96)),
      SizedBox(height: AppSizes.dp20),
      Center(
        child: BicountSkeletonBox(width: AppSizes.dp180, height: AppSizes.dp24),
      ),
      SizedBox(height: AppSizes.dp10),
      Center(
        child: BicountSkeletonBox(width: AppSizes.dp220, height: AppSizes.dp16),
      ),
      SizedBox(height: AppSizes.dp28),
      _TwoCards(height: AppSizes.dp138),
      SizedBox(height: AppDimens.spacingMedium),
      _TwoCards(height: AppSizes.dp138),
      SizedBox(height: AppDimens.spacingLarge),
      _SectionTitle(),
      SizedBox(height: AppSizes.dp12),
      _ContactRows(),
    ],
  );
}

class _TransactionPlaceholder extends StatelessWidget {
  const _TransactionPlaceholder();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
    children: const [
      SizedBox(height: AppSizes.dp20),
      _TransactionRows(),
    ],
  );
}

class _AnalysisPlaceholder extends StatelessWidget {
  const _AnalysisPlaceholder();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppDimens.paddingMedium),
    children: const [
      BicountSkeletonBox(width: AppSizes.dp160, height: AppSizes.dp22),
      SizedBox(height: AppSizes.dp14),
      BicountSkeletonBox(height: AppSizes.dp44),
      SizedBox(height: AppDimens.spacingMedium),
      _TwoCards(height: AppSizes.dp100),
      SizedBox(height: AppDimens.spacingMedium),
      BicountSkeletonBox(height: AppSizes.dp220),
      SizedBox(height: AppDimens.spacingMedium),
      BicountSkeletonBox(height: AppSizes.dp200),
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
      BicountSkeletonBox(width: AppSizes.dp140, height: AppSizes.dp22),
      BicountSkeletonBox(width: AppSizes.dp72, height: AppSizes.dp18),
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
        child: BicountSkeletonBox(height: AppSizes.dp76),
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
        child: BicountSkeletonBox(height: AppSizes.dp80),
      ),
    ),
  );
}
