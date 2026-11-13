part of 'offline_sync.dart';

extension on OfflineSync {
  void _watch<T extends OfflineModel>() => watchCodec(codecFor<T>());

  void watchCodec(OfflineCodec<dynamic> codec) {
    final ownerUserId = repository.currentUserId;
    if (_channels.containsKey(codec.table) || ownerUserId == null) {
      return;
    }
    final channel = _client.channel('bicount_sync_${codec.table}');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: codec.table,
      callback: (event) {
        unawaited(
          _applyEvent(codec, event, ownerUserId).catchError((Object error) {
            debugPrint('Realtime reconciliation for ${codec.table}: $error');
          }),
        );
      },
    );
    _channels[codec.table] = channel;
    channel.subscribe((status, error) {
      if (repository.currentUserId != ownerUserId) return;
      if (status == RealtimeSubscribeStatus.subscribed) {
        if (!OfflineJournal.enabled ||
            !_journalInUse ||
            !OfflineSync._journalTables.contains(codec.table)) {
          _lastPull.remove(codec.table);
        }
        schedule();
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        debugPrint('Realtime for ${codec.table} will reconnect: $error');
      }
    });
  }

  Future<void> _applyEvent(
    OfflineCodec<dynamic> codec,
    PostgresChangePayload event,
    String ownerUserId,
  ) async {
    final uid = repository.currentUserId;
    if (uid == null || uid != ownerUserId) return;
    if (OfflineJournal.enabled &&
        OfflineSync._journalTables.contains(codec.table)) {
      // Journal mode uses realtime only as a wake-up signal. Applying an old
      // payload after a newer journal page could otherwise regress local data.
      if (!_journalInUse) _lastPull.remove(codec.table);
      schedule();
      return;
    }
    final row = event.eventType == PostgresChangeEvent.delete
        ? event.oldRecord
        : event.newRecord;
    final id = row[codec.key]?.toString();
    if (id == null || id.isEmpty) {
      _reconcileTimers[codec.table]?.cancel();
      _reconcileTimers[codec.table] = Timer(
        const Duration(milliseconds: 500),
        () => unawaited(() async {
          try {
            await _activePulls[codec.table];
            if (repository.currentUserId == uid) await pullCodec(codec);
          } catch (error) {
            debugPrint('Delete reconciliation for ${codec.table}: $error');
          }
        }()),
      );
      return;
    }
    try {
      await _activePulls[codec.table];
    } catch (_) {
      // A failed snapshot cannot prevent a later realtime event.
    }
    final db = await repository.database();
    if (repository.currentUserId != uid) return;
    final changed = await _merge.event(
      db: db,
      codec: codec,
      userId: uid,
      id: id,
      row: event.eventType == PostgresChangeEvent.delete ? null : row,
    );
    if (changed) repository.notifyType(codec.modelType);
  }

  Future<void> _pause() async {
    final channels = _channels.values.toList();
    _channels.clear();
    _lastPull.clear();
    _journalInUse = false;
    _activePulls.clear();
    _rerunRequested = false;
    for (final timer in _reconcileTimers.values) {
      timer.cancel();
    }
    _reconcileTimers.clear();
    for (final channel in channels) {
      await _client.removeChannel(channel);
    }
  }
}
