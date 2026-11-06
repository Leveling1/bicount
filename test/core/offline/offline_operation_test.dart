import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves operation identity, owner and payload through storage', () {
    final original = OfflineOperation(
      userId: 'user-1',
      collection: 'transactions',
      recordId: 'transaction-1',
      action: 'upsert',
      payload: {'amount': 42.5, 'note': 'Déjeuner'},
      createdAt: DateTime.utc(2026, 1, 2),
    );

    final restored = OfflineOperation.fromDatabase(original.toDatabase());

    expect(restored.id, original.id);
    expect(restored.userId, 'user-1');
    expect(restored.recordId, 'transaction-1');
    expect(restored.payload, {'amount': 42.5, 'note': 'Déjeuner'});
    expect(restored.createdAt, DateTime.utc(2026, 1, 2));
  });

  test('assigns distinct identifiers to independent operations', () {
    OfflineOperation create() => OfflineOperation(
      userId: 'user-1',
      collection: 'transactions',
      recordId: 'transaction-1',
      action: 'upsert',
      payload: const {},
    );

    expect(create().id, isNot(create().id));
  });
}
