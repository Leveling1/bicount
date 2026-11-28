part of 'home_loading_skeleton.dart';

class _Transactions extends StatelessWidget {
  const _Transactions();

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('home-loading-transactions'),
    spacing: AppDimens.spacingSmall,
    children: List.generate(
      5,
      (_) => const Padding(
        padding: AppDimens.paddingSmallCard,
        child: Row(
          children: [
            BicountSkeletonCircle(size: AppDimens.transactionAvatarSize),
            AppDimens.spacerWidthMediumSmall,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BicountSkeletonBox(
                    width: AppSizes.dp130,
                    height: AppSizes.dp17,
                  ),
                  SizedBox(height: AppSizes.dp7),
                  BicountSkeletonBox(
                    width: AppSizes.dp68,
                    height: AppSizes.dp14,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimens.spacingSmall),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BicountSkeletonBox(
                  width: AppSizes.dp100,
                  height: AppSizes.dp17,
                ),
                SizedBox(height: AppSizes.dp7),
                BicountSkeletonBox(width: AppSizes.dp58, height: AppSizes.dp14),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
