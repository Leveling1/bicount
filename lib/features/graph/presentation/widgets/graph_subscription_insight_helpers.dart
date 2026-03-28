import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/subscription/presentation/models/subscription_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

SubscriptionListItem? resolveGraphSubscriptionItem(
  BuildContext context,
  UpcomingSubscriptionEntity upcoming,
) {
  final mainState = context.read<MainBloc>().state;
  if (mainState is! MainLoaded) {
    return null;
  }

  final items = buildSubscriptionListItems(mainState.startData);
  for (final item in items) {
    final itemId = item.subscription.subscriptionId ?? item.subscription.sid;
    if (itemId == upcoming.subscriptionId) {
      return item;
    }
  }
  return null;
}
