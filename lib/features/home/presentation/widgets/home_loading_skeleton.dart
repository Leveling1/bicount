import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:flutter/material.dart';

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverPersistentHeader(pinned: true, delegate: _HeaderDelegate()),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
        ),
        sliver: SliverList.list(
          children: const [
            SizedBox(height: AppDimens.spacingMedium),
            _QuickActions(),
            SizedBox(height: AppDimens.spacingMedium),
            _SectionTitle(),
            SizedBox(height: AppDimens.spacingSmall),
            _Transactions(),
          ],
        ),
      ),
    ],
  );
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 84;
  @override
  double get maxExtent => 290;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    if (progress >= 0.58) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        alignment: Alignment.center,
        child: const Row(
          children: [
            SizedBox(width: AppDimens.marginMedium),
            BicountSkeletonBox(width: 40, height: 40),
            SizedBox(width: AppDimens.marginMedium),
            Expanded(child: BicountSkeletonBox(height: 20)),
            SizedBox(width: AppDimens.marginMedium),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Column(
        children: [
          const SizedBox(height: AppDimens.paddingExtraLarge),
          const BicountSkeletonBox(width: 96, height: 18),
          const SizedBox(height: AppDimens.paddingSmall),
          const BicountSkeletonBox(width: 248, height: 36),
          const Spacer(),
          Row(
            children: const [
              Expanded(child: _SummaryCard()),
              SizedBox(width: AppDimens.marginMedium),
              Expanded(child: _SummaryCard()),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();
  @override
  Widget build(BuildContext context) => Container(
    height: 154,
    padding: AppDimens.paddingAllExtraLarge,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BicountSkeletonCircle(size: AppDimens.iconSizeLarge),
        SizedBox(height: 10),
        BicountSkeletonBox(width: 94, height: 18),
        SizedBox(height: 5),
        BicountSkeletonBox(width: 116, height: 16),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: _QuickAction()),
      const SizedBox(width: AppDimens.marginMedium),
      const Expanded(child: _QuickAction()),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction();
  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BicountSkeletonBox(width: 54, height: 18),
        BicountSkeletonCircle(size: 38),
      ],
    ),
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
