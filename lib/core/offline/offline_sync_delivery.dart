part of 'offline_sync.dart';

extension on OfflineSync {
  Future<bool> _push(String uid) async {
    final db = await repository.database();
    final outbox = OfflineOutbox(db);
    while (repository.currentUserId == uid) {
      final pending = await outbox.pending(
        uid,
        limit: 100,
        excludeUnresolvedLegacy: true,
      );
      if (pending.isEmpty) break;
      for (final operation in pending) {
        if (repository.currentUserId != uid) return false;
        try {
          if (OfflineSync._conditionalTestEnabled &&
              OfflineSync._journalTables.contains(operation.collection) &&
              (operation.action == 'upsert' || operation.action == 'delete')) {
            if (operation.isCreation && operation.action == 'upsert') {
              final delivered = await deliverConditionalCreation(
                db: db,
                client: _client,
                operation: operation,
                currentUserId: () => repository.currentUserId,
              );
              if (!delivered) {
                await outbox.defer(
                  uid,
                  operation.id,
                  StateError('Creation requires reconciliation'),
                  attempts: operation.attempts + 1,
                );
              }
              continue;
            }
            await deliverConditionalOperation(
              db: db,
              client: _client,
              operation: operation,
              currentUserId: () => repository.currentUserId,
              notify: repository.notifyType,
            );
            continue;
          } else if (operation.action == 'legacy_http') {
            await _sendLegacyRequest(operation.payload);
          } else if (operation.action == 'remote_upsert') {
            final key = operation.payload['key'] as String;
            final row = (operation.payload['row'] as Map)
                .cast<String, dynamic>();
            await _client
                .from(operation.collection)
                .upsert(
                  row,
                  onConflict: key,
                  ignoreDuplicates:
                      operation.payload['ignore_duplicates'] == true,
                )
                .timeout(const Duration(seconds: 8));
          } else if (operation.action == 'remote_update') {
            final changes = (operation.payload['changes'] as Map)
                .cast<String, dynamic>();
            final filters = (operation.payload['filters'] as Map)
                .cast<String, dynamic>();
            var request = _client.from(operation.collection).update(changes);
            for (final filter in filters.entries) {
              request = request.eq(filter.key, filter.value);
            }
            await request.timeout(const Duration(seconds: 8));
          } else if (operation.action == 'transaction_wallet' &&
              BackendEnvironment.isLocalPreproduction) {
            await _client
                .rpc('set_transaction_wallet', params: operation.payload)
                .timeout(const Duration(seconds: 8));
          } else if (operation.action == 'fcm_token') {
            await _sendFcmToken(operation.recordId, operation.payload);
          } else if (operation.action == 'delete') {
            final codec = allOfflineCodecs.firstWhere(
              (entry) => entry.table == operation.collection,
            );
            await _client
                .from(codec.table)
                .delete()
                .eq(codec.key, operation.recordId)
                .timeout(const Duration(seconds: 8));
          } else if (operation.action == 'upsert') {
            final codec = allOfflineCodecs.firstWhere(
              (entry) => entry.table == operation.collection,
            );
            if (codec.table == 'wallets' &&
                operation.payload['is_default'] == true) {
              final fields = Map<String, dynamic>.from(operation.payload)
                ..remove(codec.key)
                ..remove('owner_uid')
                ..remove('created_at')
                ..remove('is_default');
              await _client
                  .from(codec.table)
                  .update(fields)
                  .eq(codec.key, operation.recordId)
                  .select(codec.key)
                  .single()
                  .timeout(const Duration(seconds: 8));
            } else {
              await _client
                  .from(codec.table)
                  .upsert(operation.payload, onConflict: codec.key)
                  .timeout(const Duration(seconds: 8));
            }
          } else {
            throw StateError('Unsupported sync operation: ${operation.action}');
          }
          await outbox.acknowledge(uid, operation.id);
        } catch (error) {
          await outbox.defer(
            uid,
            operation.id,
            error,
            attempts: operation.attempts + 1,
          );
          return !_isTransportError(error);
        }
      }
      if (pending.length < 100) break;
    }
    return true;
  }

  bool _isTransportError(Object error) =>
      error is SocketException ||
      error is TimeoutException ||
      error is ClientException;
}
