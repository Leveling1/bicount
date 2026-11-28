import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_skeleton.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/home/presentation/widgets/home_header_sliver_layout.dart';
import 'package:bicount/features/home/presentation/widgets/home_wallet_preview.dart';
import 'package:flutter/material.dart';

part 'home_balance_skeleton.dart';
part 'home_transaction_skeleton.dart';

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      const _HomeLoadingHeader(),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
        ),
        sliver: SliverList.list(
          children: const [
            SizedBox(height: AppDimens.spacingMedium),
            _QuickActions(key: ValueKey('home-loading-actions')),
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

class _HomeLoadingHeader extends StatelessWidget {
  const _HomeLoadingHeader();

  @override
  Widget build(BuildContext context) => HomeHeaderSliverLayout(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    expanded: BackendEnvironment.walletsEnabled
        ? const Padding(
            padding: EdgeInsets.only(top: AppDimens.paddingExtraLarge),
            child: _HomeBalanceSkeleton(),
          )
        : const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
            child: _StandardBalanceSkeleton(),
          ),
    collapsed: const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: AppSizes.dp22,
      ),
      child: Row(
        children: [
          BicountSkeletonBox(width: AppSizes.dp40, height: AppSizes.dp40),
          SizedBox(width: AppDimens.marginMedium),
          Expanded(child: BicountSkeletonBox(height: AppSizes.dp20)),
        ],
      ),
    ),
  );
}

class _StandardBalanceSkeleton extends StatelessWidget {
  const _StandardBalanceSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      SizedBox(height: AppDimens.paddingExtraLarge),
      _HomeBalanceSkeleton(),
      SizedBox(height: AppDimens.spacingMedium),
      Row(
        children: [
          Expanded(child: _SummaryCard()),
          SizedBox(width: AppDimens.marginMedium),
          Expanded(child: _SummaryCard()),
        ],
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();
  @override
  Widget build(BuildContext context) => Container(
    height: AppSizes.dp154,
    padding: AppDimens.paddingAllExtraLarge,
    decoration: ShapeDecoration(
      color: Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BicountSkeletonCircle(size: AppDimens.iconSizeLarge),
        SizedBox(height: AppSizes.dp10),
        BicountSkeletonBox(width: AppSizes.dp94, height: AppSizes.dp18),
        SizedBox(height: AppSizes.dp5),
        BicountSkeletonBox(width: AppSizes.dp116, height: AppSizes.dp16),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({super.key});
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
    height: AppSizes.dp72,
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
    decoration: ShapeDecoration(
      color: Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BicountSkeletonBox(width: AppSizes.dp54, height: AppSizes.dp18),
        BicountSkeletonCircle(size: AppSizes.dp38),
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
      BicountSkeletonBox(width: AppSizes.dp140, height: AppSizes.dp22),
      BicountSkeletonBox(width: AppSizes.dp72, height: AppSizes.dp18),
    ],
  );
}
