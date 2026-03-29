import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:bicount/features/subscription/presentation/screens/detail_subscription_screen.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_bottom_sheet.dart';

Future<void> showSubscriptionDetailSheet(
  BuildContext context,
  SubscriptionListItem item,
) {
  return showCustomBottomSheet(
    context: context,
    minHeight: 0.50,
    color: null,
    child: DetailSubscription(
      friend: item.friend,
      subscription: item.subscription,
    ),
  );
}
