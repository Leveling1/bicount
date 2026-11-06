import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/core/offline/legacy_recurring_adapter.dart';
import 'package:bicount/core/offline/legacy_uuid.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';

Future<SubscriptionModel?> findSubscription(String subscriptionId) async {
  final items = await Repository().get<RecurringTransfertModel>(
    policy: OfflineReadPolicy.localOnly,
    query: Query(
      where: [
        Where.exact(
          'recurringTransfertId',
          canonicalLegacyUuid('subscriptions', subscriptionId),
        ),
      ],
    ),
  );
  return items.isEmpty ? null : subscriptionFromRecurring(items.first);
}
