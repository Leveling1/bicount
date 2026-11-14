part of 'home_loading_skeleton.dart';

class _Transactions extends StatelessWidget {
  const _Transactions();
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      5,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: AppDimens.spacingSmall),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              BicountSkeletonCircle(size: 40),
              SizedBox(width: AppDimens.marginMedium),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BicountSkeletonBox(width: 130, height: 17),
                    SizedBox(height: 7),
                    BicountSkeletonBox(width: 68, height: 14),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.marginSmall),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BicountSkeletonBox(width: 100, height: 17),
                  SizedBox(height: 7),
                  BicountSkeletonBox(width: 58, height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
