import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';
import 'offline_codecs.g.dart';
import 'offline_conflict_clock.dart';
import 'offline_conditional_delivery.dart';
import 'offline_conditional_creation.dart';
import 'offline_fresh_snapshot.dart';
import 'offline_legacy_finance_migration.dart';
import 'offline_legacy_acknowledgement.dart';
import 'offline_legacy_finance_reconcile.dart';
import 'offline_journal.dart';
import 'offline_remote_snapshot.dart';
import '../constants/backend_environment.dart';
import 'offline_model.dart';
import 'offline_merge.dart';
import 'outbox/offline_outbox.dart';
import 'repository.dart';

part 'offline_sync_delivery.dart';
part 'offline_sync_network.dart';
part 'offline_sync_snapshot.dart';
part 'offline_sync_realtime.dart';

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
  bool _journalInUse = false;
  DateTime? _lastClockSample;
  bool _samplingClock = false;
  static const _conditionalTestEnabled = BackendEnvironment.isConditionalTest;

  static const _journalTables = {
    'users',
    'friends',
    'transactions',
    'debts',
    'recurring_transfert',
  };

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
    if (_conditionalTestEnabled) unawaited(_sampleConflictClock(uid));
    try {
      final db = await repository.database();
      if (repository.legacyMigrationPending) return;
      if (await hasLegacyFinanceCandidates(db)) {
        try {
          final candidates = await db.query(
            'bicount_legacy_finance_candidates',
            columns: ['target_table'],
            distinct: true,
          );
          final tables = candidates.map((row) => row['target_table']).toSet();
          for (final codec in [
            transactionModelCodec,
            recurringTransfertModelCodec,
          ]) {
            if (!tables.contains(codec.table)) continue;
            final last = _lastPull[codec.table];
            if (last == null ||
                DateTime.now().difference(last) > const Duration(minutes: 5)) {
              await pullCodec(codec);
            }
          }
        } catch (error) {
          debugPrint('Legacy finance reconciliation will retry: $error');
          return;
        }
      }
      if (!await _push(uid)) return;
      var journalActive = false;
      if (OfflineJournal.enabled) {
        try {
          journalActive = await OfflineJournal(
            client: _client,
            db: db,
            userId: uid,
            currentUserId: () => repository.currentUserId,
            snapshot: _freshJournalSnapshot,
            notify: repository.notifyType,
          ).synchronize();
        } catch (error) {
          debugPrint('Journal sync unavailable; using snapshots: $error');
        }
      }
      if (_journalInUse && !journalActive) _lastPull.clear();
      _journalInUse = journalActive;
      for (final codec in allOfflineCodecs.where(_isEagerCollection)) {
        if (repository.currentUserId != uid) return;
        watchCodec(codec);
        final last = _lastPull[codec.table];
        final journalCollection = _journalTables.contains(codec.table);
        final interval = journalActive && journalCollection
            ? const Duration(hours: 1)
            : const Duration(minutes: 5);
        if (last == null || DateTime.now().difference(last) > interval) {
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

  Future<void> _sampleConflictClock(String uid) async {
    final now = DateTime.now().toUtc();
    if (_samplingClock ||
        (_lastClockSample != null &&
            now.difference(_lastClockSample!).abs() <
                const Duration(minutes: 5))) {
      return;
    }
    _samplingClock = true;
    final clock = OfflineConflictClock.instance;
    final started = clock.beginSample();
    try {
      final result = await _client
          .rpc('bicount_server_clock')
          .timeout(const Duration(seconds: 5));
      if (repository.currentUserId != uid || result is! String) return;
      final server = DateTime.tryParse(result);
      if (server == null) return;
      clock.completeSample(started, server);
      _lastClockSample = DateTime.now().toUtc();
    } catch (_) {
      // Unknown clock means conflicts remain queued, never an assumed winner.
    } finally {
      _samplingClock = false;
    }
  }

  Future<void> pull<T extends OfflineModel>() => _pull<T>();

  void watch<T extends OfflineModel>() => _watch<T>();

  Future<void> pause() => _pause();
}
