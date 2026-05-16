import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:bicount/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';

class ProfileSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  ProfileSliverHeaderDelegate({
    required this.image,
    required this.name,
    required this.email,
    required this.balance,
    required this.totalLabel,
    required this.onTap,
  });

  final String image;
  final String name;
  final String email;
  final double balance;
  final String totalLabel;
  final VoidCallback onTap;

  @override
  double get minExtent => 84;

  @override
  double get maxExtent => 210;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collapseProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final isCollapsed = collapseProgress >= 0.56;
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: balance >= 0 ? null : Colors.red,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusUltraLarge),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isCollapsed
            ? _CollapsedProfileHeader(
                key: const ValueKey('profile-collapsed'),
                image: image,
                name: name,
                totalLabel: totalLabel,
                balanceText: NumberFormatUtils.compactCurrency(
                  balance,
                  compactThreshold: 100000,
                ),
                amountStyle: amountStyle,
                onTap: onTap,
              )
            : Padding(
                key: const ValueKey('profile-expanded'),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingExtraSmall,
                ),
                child: ProfileCard(
                  image: image,
                  name: name,
                  email: email,
                  balance: balance,
                  onTap: onTap,
                ),
              ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ProfileSliverHeaderDelegate oldDelegate) {
    return image != oldDelegate.image ||
        name != oldDelegate.name ||
        email != oldDelegate.email ||
        balance != oldDelegate.balance ||
        totalLabel != oldDelegate.totalLabel ||
        onTap != oldDelegate.onTap;
  }
}

class _CollapsedProfileHeader extends StatelessWidget {
  const _CollapsedProfileHeader({
    super.key,
    required this.image,
    required this.name,
    required this.totalLabel,
    required this.balanceText,
    required this.amountStyle,
    required this.onTap,
  });

  final String image;
  final String name;
  final String totalLabel;
  final String balanceText;
  final TextStyle amountStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusUltraLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
          child: Row(
            children: [
              AppAvatar(image: image, radius: 18),
              const SizedBox(width: AppDimens.marginMedium),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppDimens.marginSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(totalLabel, style: theme.textTheme.labelSmall),
                  Text(balanceText, style: amountStyle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
