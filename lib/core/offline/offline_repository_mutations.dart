part of 'repository.dart';

extension OfflineRepositoryMutations on Repository {
  Future<T> upsert<T extends OfflineModel>(
    T model, {
    bool isCreation = false,
  }) async {
    final codec = codecFor<T>();
    final local = codec.toLocal(model);
    final remote = codec.toRemote(model);
    final id = remote[codec.key]?.toString();
    if (id == null || id.isEmpty) throw StateError('Missing ${codec.key}');
    final (uid, db) = await _writableDatabase();
    if (BackendEnvironment.isLocalPreproduction) {
      await retainOwnWalletPointers(db, uid, remote);
    }
    final editTime = BackendEnvironment.isConditionalTest
        ? OfflineConflictClock.instance.estimate()
        : null;
    final operation = OfflineOperation(
      userId: uid,
      collection: codec.table,
      recordId: id,
      action: 'upsert',
      payload: remote,
      isCreation: isCreation,
      editedEarliest: editTime?.earliest,
      editedLatest: editTime?.latest,
    );
    await OfflineOutbox(db).commit(operation, (tx) async {
      await tx.insert(
        codec.localTable,
        local,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    _changes.add(T);
    _sync.schedule();
    return model;
  }

  Future<void> delete<T extends OfflineModel>(T model) async {
    final codec = codecFor<T>();
    final id = codec.toRemote(model)[codec.key]?.toString();
    if (id == null || id.isEmpty) throw StateError('Missing ${codec.key}');
    final (uid, db) = await _writableDatabase();
    final editTime = BackendEnvironment.isConditionalTest
        ? OfflineConflictClock.instance.estimate()
        : null;
    final operation = OfflineOperation(
      userId: uid,
      collection: codec.table,
      recordId: id,
      action: 'delete',
      payload: {codec.key: id},
      editedEarliest: editTime?.earliest,
      editedLatest: editTime?.latest,
    );
    await OfflineOutbox(db).commit(operation, (tx) async {
      await tx.delete(
        codec.localTable,
        where: '"${codec.localKey}" = ?',
        whereArgs: [id],
      );
    });
    _changes.add(T);
    _sync.schedule();
  }

  Future<void> queueRemoteUpsert({
    required String table,
    required String key,
    required String recordId,
    required Map<String, Object?> row,
    bool ignoreDuplicates = false,
  }) async {
    if (table.isEmpty ||
        key.isEmpty ||
        recordId.isEmpty ||
        row[key]?.toString() != recordId) {
      throw ArgumentError('A remote upsert needs a stable row identifier.');
    }
    final (uid, db) = await _writableDatabase();
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: table,
        recordId: recordId,
        action: 'remote_upsert',
        payload: {
          'key': key,
          'row': row,
          'ignore_duplicates': ignoreDuplicates,
        },
      ),
      (_) async {},
    );
    _sync.schedule();
  }

  Future<void> queueRemoteUpdate({
    required String table,
    required String recordId,
    required Map<String, Object?> filters,
    required Map<String, Object?> changes,
  }) async {
    if (table.isEmpty ||
        recordId.isEmpty ||
        filters.isEmpty ||
        changes.isEmpty) {
      throw ArgumentError('A remote update needs filters and changes.');
    }
    final (uid, db) = await _writableDatabase();
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: table,
        recordId: recordId,
        action: 'remote_update',
        payload: {'filters': filters, 'changes': changes},
      ),
      (_) async {},
    );
    _sync.schedule();
  }

  Future<void> queueFcmToken({
    required String userId,
    required Map<String, Object?> row,
  }) async {
    if (userId.isEmpty ||
        row['user_uid'] != userId ||
        currentUserId != userId) {
      throw ArgumentError('An FCM token needs its user identifier.');
    }
    final (uid, db) = await _writableDatabase();
    if (uid != userId) {
      throw StateError('The account changed before token persistence.');
    }
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: 'fcm_tokens',
        recordId: userId,
        action: 'fcm_token',
        payload: row,
      ),
      (_) async {},
    );
    _sync.schedule();
  }
}
