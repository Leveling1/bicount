import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_card.dart';
import 'package:flutter/material.dart';

class SubscriptionItemList extends StatelessWidget {
  const SubscriptionItemList({
    super.key,
    required this.items,
    required this.onTap,
    this.emptyMessage,
  });

  final List<SubscriptionListItem> items;
  final ValueChanged<SubscriptionListItem> onTap;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _SubscriptionEmptyState(
        message: emptyMessage ?? context.l10n.analysisNoActiveSubscriptions,
      );
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return BicountReveal(
          delay: Duration(milliseconds: 130 + (index * 40)),
          child: SubscriptionCard(item: item, onTap: () => onTap(item)),
        );
      }),
    );
  }
}

class _SubscriptionEmptyState extends StatelessWidget {
  const _SubscriptionEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: AppDimens.iconSizeLarge,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
