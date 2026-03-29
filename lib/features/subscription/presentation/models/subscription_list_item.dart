import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';

class SubscriptionListItem {
  const SubscriptionListItem({
    required this.subscription,
    required this.friend,
    required this.monthlyAmount,
    this.nextBilling,
    this.endDate,
  });

  final SubscriptionModel subscription;
  final FriendsModel friend;
  final double monthlyAmount;
  final DateTime? nextBilling;
  final DateTime? endDate;

  bool get isActive => subscription.status == SubscriptionConst.active;

  String get searchText =>
      '${subscription.title} ${friend.username} ${subscription.notes ?? ''}'
          .toLowerCase();
}

List<SubscriptionListItem> buildSubscriptionListItems(MainEntity data) {
  final subscriptionFriends = {
    for (final friend in data.friends)
      if (friend.relationType == FriendConst.subscription) friend.sid: friend,
  };

  final items = data.subscriptions.map((subscription) {
    final subscriptionKey = subscription.subscriptionId ?? '';
    final linkedFriend =
        subscriptionFriends[subscriptionKey] ??
        FriendsModel(
          sid: subscriptionKey,
          uid: null,
          fid: data.user.uid,
          image: '',
          username: subscription.title,
          email: '',
          give: 0,
          receive: 0,
          relationType: FriendConst.subscription,
          personalIncome: 0,
          companyIncome: 0,
        );

    return SubscriptionListItem(
      subscription: subscription,
      friend: linkedFriend,
      monthlyAmount: _monthlyAmount(subscription),
      nextBilling: _parseDate(subscription.nextBillingDate),
      endDate: _parseDate(subscription.endDate),
    );
  }).toList();

  items.sort((left, right) {
    if (left.isActive != right.isActive) {
      return left.isActive ? -1 : 1;
    }

    final leftDate = left.nextBilling ?? DateTime(9999);
    final rightDate = right.nextBilling ?? DateTime(9999);
    return leftDate.compareTo(rightDate);
  });

  return items;
}

double _monthlyAmount(SubscriptionModel subscription) {
  switch (subscription.frequency) {
    case Frequency.weekly:
      return subscription.amount * 52 / 12;
    case Frequency.monthly:
      return subscription.amount;
    case Frequency.quarterly:
      return subscription.amount / 3;
    case Frequency.yearly:
      return subscription.amount / 12;
    case Frequency.oneTime:
    default:
      return 0;
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

List<SubscriptionListItem> filterSubscriptionListItems(
  List<SubscriptionListItem> items,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return items;
  }

  return items
      .where((item) => item.searchText.contains(normalizedQuery))
      .toList();
}
