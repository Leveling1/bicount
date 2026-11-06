import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';
import 'offline_codecs.g.dart';
import 'offline_legacy_finance_migration.dart';
import 'offline_legacy_finance_reconcile.dart';
import '../constants/secrets.dart';
import 'offline_model.dart';
import 'offline_merge.dart';
import 'outbox/offline_outbox.dart';
import 'repository.dart';

/// Pushes durable local intents, then reconciles changes made on Supabase.
class OfflineSync {
  OfflineSync(this.repository);

  final Repository repository;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, DateTime> _lastPull = {};
  final Map<String, Future<void>> _activePulls = {};
  final Map<String, Timer> _reconcileTimers = {};
  final HttpClient _legacyClient = HttpClient();
  final OfflineMerge _merge = const OfflineMerge();
  Timer? _timer;
  Future<void>? _active;
  String? _runningUserId;
  bool _rerunRequested = false;

  SupabaseClient get _client => Supabase.instance.client;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 20), (_) => schedule());
  }

  void schedule() {
    if (_active != null) {
      _rerunRequested = true;
      return;
    }
    unawaited(run());
  }

  Future<void> run() {
    final current = _active;
    if (current != null) {
      if (_runningUserId != repository.currentUserId) {
        _rerunRequested = true;
      }
      return current;
    }
    _runningUserId = repository.currentUserId;
    final future = _run();
    _active = future;
    return future.whenComplete(() {
      _active = null;
      _runningUserId = null;
      if (_rerunRequested) {
        _rerunRequested = false;
        schedule();
      }
    });
  }

  Future<void> _run() async {
    final uid = repository.currentUserId;
    if (uid == null) return;
    try {
      final db = await repository.database();
      if (repository.legacyMigrationPending) return;
      if (await hasLegacyFinanceCandidates(db)) {
        try {
          await pullCodec(transactionModelCodec);
          await pullCodec(recurringTransfertModelCodec);
        } catch (error) {
          debugPrint('Legacy finance reconciliation will retry: $error');
          return;
        }
      }
      if (!await _push(uid)) return;
      for (final codec in allOfflineCodecs.where(_isEagerCollection)) {
        if (repository.currentUserId != uid) return;
        watchCodec(codec);
        final last = _lastPull[codec.table];
        if (last == null ||
            DateTime.now().difference(last) > const Duration(minutes: 5)) {
          try {
            await pullCodec(codec);
          } catch (error) {
            debugPrint('Pull for ${codec.table} will retry: $error');
            if (_isTransportError(error)) return;
          }
        }
      }
    } catch (error) {
      debugPrint('Offline sync will retry: $error');
    }
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

  Future<bool> _push(String uid) async {
    final db = await repository.database();
    final outbox = OfflineOutbox(db);
    while (repository.currentUserId == uid) {
      final pending = await outbox.pending(uid, limit: 100);
      if (pending.isEmpty) break;
      for (final operation in pending) {
        if (repository.currentUserId != uid) return false;
        try {
          if (operation.action == 'legacy_http') {
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
            await _client
                .from(codec.table)
                .upsert(operation.payload, onConflict: codec.key)
                .timeout(const Duration(seconds: 8));
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

  Future<void> _sendFcmToken(String userId, Map<String, Object?> row) async {
    final existing = await _client
        .from('fcm_tokens')
        .select('token_id')
        .eq('user_uid', userId)
        .timeout(const Duration(seconds: 8));
    if (existing.isEmpty) {
      await _client
          .from('fcm_tokens')
          .insert(row)
          .timeout(const Duration(seconds: 8));
      return;
    }
    final firstId = existing.first['token_id']?.toString();
    if (firstId == null || firstId.isEmpty) {
      await _client
          .from('fcm_tokens')
          .update(row)
          .eq('user_uid', userId)
          .timeout(const Duration(seconds: 8));
      return;
    }
    await _client
        .from('fcm_tokens')
        .update(row)
        .eq('token_id', firstId)
        .timeout(const Duration(seconds: 8));
    await _client
        .from('fcm_tokens')
        .delete()
        .eq('user_uid', userId)
        .neq('token_id', firstId)
        .timeout(const Duration(seconds: 8));
  }

  Future<void> _sendLegacyRequest(Map<String, Object?> payload) async {
    final uri = Uri.parse(payload['url'] as String);
    final project = Uri.parse(Secrets.projectUrl);
    if (uri.scheme != project.scheme ||
        uri.host != project.host ||
        uri.port != project.port) {
      throw StateError('Legacy request target differs from this project.');
    }
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) throw StateError('No session for queued request.');
    final request = await _legacyClient
        .openUrl(payload['method'] as String, uri)
        .timeout(const Duration(seconds: 15));
    final headers = jsonDecode(payload['headers'] as String) as Map;
    for (final entry in headers.entries) {
      final name = entry.key.toString().toLowerCase();
      if (name == 'authorization' ||
          name == 'apikey' ||
          name == 'content-length' ||
          name == 'host') {
        continue;
      }
      request.headers.set(name, entry.value.toString());
    }
    request.headers.set('apikey', Secrets.anonKey);
    request.headers.set('authorization', 'Bearer $token');
    request.write(payload['body'] as String? ?? '');
    final response = await request.close().timeout(const Duration(seconds: 20));
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Queued request returned ${response.statusCode}');
    }
  }

  Future<void> pull<T extends OfflineModel>() {
    final codec = codecFor<T>();
    final last = _lastPull[codec.table];
    if (last != null &&
        DateTime.now().difference(last) < const Duration(seconds: 30)) {
      return Future.value();
    }
    return pullCodec(codec);
  }

  Future<void> pullCodec(OfflineCodec<dynamic> codec) {
    final active = _activePulls[codec.table];
    if (active != null) return active;
    late final Future<void> tracked;
    tracked = _pullCodec(codec).whenComplete(() {
      if (identical(_activePulls[codec.table], tracked)) {
        _activePulls.remove(codec.table);
      }
    });
    _activePulls[codec.table] = tracked;
    return tracked;
  }

  Future<void> _pullCodec(OfflineCodec<dynamic> codec) async {
    final uid = repository.currentUserId;
    if (uid == null) return;
    await repository.database();
    if (repository.legacyMigrationPending) return;
    const pageSize = 500;
    String? lastId;
    final remoteRows = <Map<String, dynamic>>[];
    while (repository.currentUserId == uid) {
      final request = _client.from(codec.table).select();
      final page = lastId == null
          ? await request
                .order(codec.key)
                .limit(pageSize)
                .timeout(const Duration(seconds: 8))
          : await request
                .gt(codec.key, lastId)
                .order(codec.key)
                .limit(pageSize)
                .timeout(const Duration(seconds: 8));
      remoteRows.addAll(page);
      if (page.length < pageSize) break;
      lastId = page.last[codec.key]?.toString();
      if (lastId == null || lastId.isEmpty) {
        throw StateError('Cannot page ${codec.table} without ${codec.key}');
      }
    }
    if (repository.currentUserId != uid) return;
    final db = await repository.database();
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
    );
    _lastPull[codec.table] = DateTime.now();
    repository.notifyType(codec.modelType);
  }

  void watch<T extends OfflineModel>() => watchCodec(codecFor<T>());

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
    channel.subscribe();
  }

  Future<void> _applyEvent(
    OfflineCodec<dynamic> codec,
    PostgresChangePayload event,
    String ownerUserId,
  ) async {
    final uid = repository.currentUserId;
    if (uid == null || uid != ownerUserId) return;
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

  Future<void> pause() async {
    final channels = _channels.values.toList();
    _channels.clear();
    _lastPull.clear();
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
