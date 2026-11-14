part of 'home_sliver_header.dart';

class _CollapsedHomeHeader extends StatelessWidget {
  const _CollapsedHomeHeader({
    super.key,
    required this.balanceText,
    required this.amountStyle,
  });

  final String balanceText;
  final TextStyle amountStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.borderRadiusLarge),
          bottomRight: Radius.circular(AppDimens.borderRadiusLarge),
        ),
      ),
      child: Center(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(left: AppDimens.marginMedium),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  IconLinks.wallet,
                  width: AppDimens.iconSizeMedium,
                  height: AppDimens.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    theme.textTheme.titleMedium!.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.marginMedium),
            Expanded(
              child: Text(
                context.l10n.homeBalance,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: AppDimens.marginSmall),
            Text(balanceText, style: amountStyle),
            const SizedBox(width: AppDimens.marginMedium),
          ],
        ),
      ),
    );
  }
}
