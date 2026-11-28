part of 'home_loading_skeleton.dart';

class _HomeBalanceSkeleton extends StatelessWidget {
  const _HomeBalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    const label = BicountSkeletonBox(
      width: AppSizes.dp96,
      height: AppSizes.dp18,
    );
    const spacing = SizedBox(height: AppDimens.paddingSmall);
    if (!BackendEnvironment.walletsEnabled) {
      return const Column(
        children: [
          label,
          spacing,
          BicountSkeletonBox(width: AppSizes.dp248, height: AppSizes.dp36),
        ],
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
              BicountSkeletonBox(width: AppSizes.dp200, height: AppSizes.dp36),
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
                      radius: AppSizes.dp14,
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
                BicountSkeletonBox(width: AppSizes.dp78, height: AppSizes.dp16),
                SizedBox(height: AppDimens.spacingExtraSmall),
                BicountSkeletonBox(
                  width: AppSizes.dp106,
                  height: AppSizes.dp14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
