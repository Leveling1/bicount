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
    expanded: BackendEnvironment.isLocalPreproduction
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
        vertical: 22,
      ),
      child: Row(
        children: [
          BicountSkeletonBox(width: 40, height: 40),
          SizedBox(width: AppDimens.marginMedium),
          Expanded(child: BicountSkeletonBox(height: 20)),
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
    height: 154,
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
        SizedBox(height: 10),
        BicountSkeletonBox(width: 94, height: 18),
        SizedBox(height: 5),
        BicountSkeletonBox(width: 116, height: 16),
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
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: ShapeDecoration(
      color: Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
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
