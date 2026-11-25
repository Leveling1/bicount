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
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AppDimens.paddingMedium,
            0,
            HomeWalletPreview.width + AppDimens.paddingSmall,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        PositionedDirectional(
          end: 0,
          top: 0,
          bottom: 0,
          width: HomeWalletPreview.width,
          child: ClipRect(
            key: const ValueKey('home-wallet-skeleton'),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: constraints.maxHeight * WalletCardFace.aspectRatio,
                    child: BicountSkeletonBox(
                      height: constraints.maxHeight,
                      radius: 14,
                      preserveWalletCorners: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyBalanceSkeleton extends StatelessWidget {
  const _MonthlyBalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
      child: Row(
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
      ),
    );
  }
}
