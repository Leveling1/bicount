part of 'offline_sync.dart';

extension on OfflineSync {
  Future<void> _pull<T extends OfflineModel>() {
    final codec = codecFor<T>();
    final last = _lastPull[codec.table];
    if (last != null &&
        DateTime.now().difference(last) < const Duration(seconds: 30)) {
      return Future.value();
    }
    return pullCodec(codec);
  }

  Future<void> pullCodec(
    OfflineCodec<dynamic> codec, {
    int? observedSequence,
    int? observedGeneration,
  }) {
    final active = _activePulls[codec.table];
    if (active != null) return active;
    late final Future<void> tracked;
    tracked =
        _pullCodec(
          codec,
          observedSequence: observedSequence,
          observedGeneration: observedGeneration,
        ).whenComplete(() {
          if (identical(_activePulls[codec.table], tracked)) {
            _activePulls.remove(codec.table);
          }
        });
    _activePulls[codec.table] = tracked;
    return tracked;
  }

  /// A journal watermark is read before this call. An older in-flight pull
  /// must finish first; otherwise it could be mistaken for a fresh snapshot.
  Future<void> _freshJournalSnapshot(
    OfflineCodec<dynamic> codec,
    int sequence,
    int generation,
  ) async {
    final uid = repository.currentUserId;
    await refreshAfterOlderPull(
      olderPull: _activePulls[codec.table],
      isCurrentAccount: () => uid != null && repository.currentUserId == uid,
      refresh: () => pullCodec(
        codec,
        observedSequence: sequence,
        observedGeneration: generation,
      ),
    );
  }

  Future<void> _pullCodec(
    OfflineCodec<dynamic> codec, {
    int? observedSequence,
    int? observedGeneration,
  }) async {
    final uid = repository.currentUserId;
    if (uid == null) return;
    final db = await repository.database();
    if (repository.legacyMigrationPending) return;
    if (observedSequence == null &&
        observedGeneration == null &&
        _journalInUse &&
        OfflineSync._journalTables.contains(codec.table)) {
      final markers = await db.query(
        'bicount_journal_cursor',
        columns: ['sequence', 'generation'],
        where: 'user_id = ?',
        whereArgs: [uid],
        limit: 1,
      );
      if (markers.isNotEmpty) {
        observedSequence = (markers.single['sequence'] as num).toInt();
        observedGeneration = (markers.single['generation'] as num).toInt();
      }
    }
    final remoteRows = await fetchOfflineRemoteSnapshot(
      client: _client,
      codec: codec,
      isCurrentUser: () => repository.currentUserId == uid,
    );
    if (repository.currentUserId != uid) return;
    await acknowledgeIdenticalLegacyUpserts(
      db: db,
      userId: uid,
      table: codec.table,
      key: codec.key,
      remoteRows: remoteRows,
    );
    await reconcileLegacyFinanceCandidates(
      db: db,
      codec: codec,
      userId: uid,
      remoteRows: remoteRows,
    );
    final pending = await db.query(
      'bicount_sync_outbox',
      columns: ['record_id'],
      where: 'user_id = ? AND collection = ?',
      whereArgs: [uid, codec.table],
    );
    final pendingIds = pending
        .map((row) => row['record_id'].toString())
        .toSet();
    final candidates = await db.query(
      'bicount_legacy_finance_candidates',
      columns: ['target_id'],
      where: 'target_table = ?',
      whereArgs: [codec.table],
    );
    pendingIds.addAll(candidates.map((row) => row['target_id'].toString()));
    final remoteIds = remoteRows
        .map((row) => row[codec.key]?.toString())
        .whereType<String>()
        .toSet();
    final localIds = await db.query(
      codec.localTable,
      columns: [codec.localKey],
    );
    final absentIds = localIds
        .map((row) => row[codec.localKey]?.toString())
        .whereType<String>()
        .where((id) => !remoteIds.contains(id) && !pendingIds.contains(id));
    final confirmedDeletes = <String>[];
    for (final id in absentIds) {
      final stillRemote = await _client
          .from(codec.table)
          .select(codec.key)
          .eq(codec.key, id)
          .maybeSingle()
          .timeout(const Duration(seconds: 8));
      if (stillRemote == null) confirmedDeletes.add(id);
    }
    if (repository.currentUserId != uid) return;
    await _merge.snapshot(
      db: db,
      codec: codec,
      userId: uid,
      rows: remoteRows,
      confirmedDeletes: confirmedDeletes,
      observedSequence: observedSequence,
      observedGeneration: observedGeneration,
    );
    _lastPull[codec.table] = DateTime.now();
    repository.notifyType(codec.modelType);
  }

  bool _isEagerCollection(OfflineCodec<dynamic> codec) {
    if (codec.table == 'memoji') return false;
    if (AppConfig.exposeCompanySurface) return true;
    return !const {
      'companies',
      'company_with_user_link',
      'projects',
      'groups',
    }.contains(codec.table);
  }
}
