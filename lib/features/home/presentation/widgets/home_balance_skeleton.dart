part of 'home_loading_skeleton.dart';

class _HomeBalanceSkeleton extends StatelessWidget {
  const _HomeBalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    const label = BicountSkeletonBox(width: 96, height: 18);
    const spacing = SizedBox(height: AppDimens.paddingSmall);
    if (!BackendEnvironment.isLocalPreproduction) {
      return const Column(
        children: [label, spacing, BicountSkeletonBox(width: 248, height: 36)],
      );
    }
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label,
              spacing,
              BicountSkeletonBox(width: 200, height: 36),
              SizedBox(height: AppDimens.spacingMedium),
              _MonthlyBalanceSkeleton(),
              SizedBox(height: AppDimens.spacingSmall),
              _MonthlyBalanceSkeleton(),
            ],
          ),
        ),
        SizedBox(width: AppDimens.paddingSmall),
        BicountSkeletonBox(width: 62, height: 164),
      ],
    );
  }
}

class _MonthlyBalanceSkeleton extends StatelessWidget {
  const _MonthlyBalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BicountSkeletonCircle(size: AppDimens.iconSizeLarge),
        SizedBox(width: AppDimens.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BicountSkeletonBox(width: 78, height: 16),
              SizedBox(height: 4),
              BicountSkeletonBox(width: 106, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
