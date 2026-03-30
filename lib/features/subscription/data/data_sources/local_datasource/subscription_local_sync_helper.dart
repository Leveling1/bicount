import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';

Future<SubscriptionModel?> findSubscription(String subscriptionId) async {
  final items = await Repository().get<SubscriptionModel>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where.exact('subscriptionId', subscriptionId)]),
  );
  return items.isEmpty ? null : items.first;
}

Future<void> syncSubscriptionCompanions({
  required String currentUserId,
  required SubscriptionModel subscription,
}) async {
  final subscriptionId = subscription.subscriptionId;
  if (subscriptionId == null || subscriptionId.isEmpty) {
    return;
  }

  final existingFriend = await _findFriend(subscriptionId);
  await Repository().upsert<FriendsModel>(
    FriendsModel(
      sid: subscriptionId,
      uid: null,
      fid: currentUserId,
      username: subscription.title,
      email: existingFriend?.email ?? '',
      image: existingFriend?.image ?? '',
      give: existingFriend?.give ?? 0,
      receive: existingFriend?.receive ?? 0,
      relationType: FriendConst.subscription,
      personalIncome: existingFriend?.personalIncome ?? 0,
      companyIncome: existingFriend?.companyIncome ?? 0,
    ),
  );

  final existingTransaction = await _findSubscriptionTransaction(
    currentUserId,
    subscriptionId,
  );
  if (existingTransaction == null) {
    return;
  }

  await Repository().upsert<TransactionModel>(
    TransactionModel(
      tid: existingTransaction.tid,
      uid: currentUserId,
      gtid: existingTransaction.gtid,
      name: subscription.title,
      type: TransactionTypes.subscriptionCode,
      beneficiaryId: subscriptionId,
      senderId: currentUserId,
      date: subscription.startDate,
      note: subscription.notes ?? '',
      amount: subscription.amount,
      currency: subscription.currency,
      referenceCurrencyCode: subscription.referenceCurrencyCode,
      convertedAmount: subscription.convertedAmount,
      amountCdf: subscription.amountCdf,
      rateToCdf: subscription.rateToCdf,
      fxRateDate: subscription.fxRateDate,
      fxSnapshotId: subscription.fxSnapshotId,
      image: existingTransaction.image,
      frequency: subscription.frequency,
      category: subscription.category,
      createdAt: existingTransaction.createdAt,
    ),
  );
}

Future<FriendsModel?> _findFriend(String sid) async {
  final items = await Repository().get<FriendsModel>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where.exact('sid', sid)]),
  );
  return items.isEmpty ? null : items.first;
}

Future<TransactionModel?> _findSubscriptionTransaction(
  String currentUserId,
  String subscriptionId,
) async {
  final items = await Repository().get<TransactionModel>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(
      where: [
        Where.exact('senderId', currentUserId),
        Where.exact('beneficiaryId', subscriptionId),
        Where.exact('type', TransactionTypes.subscriptionCode),
      ],
    ),
  );
  return items.isEmpty ? null : items.first;
}
