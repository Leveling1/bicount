import 'dart:async';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_codecs.g.dart';
import 'offline_merge.dart';

/// Incremental pull. Disabled unless explicitly enabled at build time and for
/// the authenticated account on the server.
class OfflineJournal {
  OfflineJournal({
    required this.client,
    required this.db,
    required this.userId,
    required this.currentUserId,
    required this.snapshot,
    required this.notify,
  });

  final SupabaseClient client;
  final Database db;
  final String userId;
  final String? Function() currentUserId;

  /// Attach the supplied marker only to rows this fresh snapshot observes.
  final Future<void> Function(OfflineCodec<dynamic>, int, int) snapshot;
  final void Function(Type) notify;
  static const enabled = bool.fromEnvironment('BICOUNT_SYNC_JOURNAL');
  static const _merge = OfflineMerge();

  static final _codecs = <String, OfflineCodec<dynamic>>{
    for (final codec in [
      userModelCodec,
      friendsModelCodec,
      transactionModelCodec,
      debtModelCodec,
      recurringTransfertModelCodec,
    ])
      codec.table: codec,
  };

  void _checkUser() {
    if (currentUserId() != userId) {
      throw StateError('Account changed during journal synchronization.');
    }
  }

  Future<bool> synchronize() async {
    _checkUser();
    final result = await client
        .rpc('bicount_sync_status')
        .timeout(const Duration(seconds: 8));
    final status = Map<String, dynamic>.from(result as Map);
    if (status['enabled'] != true) return false;
    final latest = (status['latest_sequence'] as num).toInt();
    final oldest = (status['oldest_available_sequence'] as num).toInt();
    final generation = (status['generation'] as num).toInt();
    await db.execute(
      'CREATE TABLE IF NOT EXISTS bicount_journal_cursor '
      '(user_id TEXT PRIMARY KEY, sequence INTEGER NOT NULL, '
      'generation INTEGER NOT NULL DEFAULT 0)',
    );
    final columns = await db.rawQuery(
      'PRAGMA table_info(bicount_journal_cursor)',
    );
    if (!columns.any((column) => column['name'] == 'generation')) {
      await db.execute(
        'ALTER TABLE bicount_journal_cursor '
        'ADD COLUMN generation INTEGER NOT NULL DEFAULT 0',
      );
    }
    final rows = await db.query(
      'bicount_journal_cursor',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    final stored = rows.isEmpty
        ? null
        : (rows.single['sequence'] as num).toInt();
    final storedGeneration = rows.isEmpty
        ? null
        : (rows.single['generation'] as num).toInt();
    var cursor = stored ?? latest;
    if (stored == null ||
        stored < oldest - 1 ||
        stored > latest ||
        storedGeneration != generation) {
      // Read the clock before snapshots, then replay everything since it.
      for (final codec in _codecs.values) {
        _checkUser();
        await snapshot(codec, latest, generation);
      }
      _checkUser();
      await db.transaction((tx) async {
        _checkUser();
        _checkUser();
        await _saveCursor(tx, latest, generation);
      });
      cursor = latest;
    }

    // Bound work per pass; the next periodic pass resumes at the saved cursor.
    for (var pageNumber = 0; pageNumber < 10; pageNumber++) {
      _checkUser();
      final page = await client
          .from('bicount_sync_events')
          .select('sequence,table_name,record_id,change_kind')
          .eq('user_uid', userId)
          .gt('sequence', cursor)
          .order('sequence', ascending: true)
          .limit(100)
          .timeout(const Duration(seconds: 8));
      if (page.isEmpty) break;
      final records = <String, Map<String, String>>{};
      final invalidated = <String>{};
      var last = cursor;
      for (final event in page) {
        final sequence = (event['sequence'] as num).toInt();
        if (sequence != last + 1) {
          await db.delete(
            'bicount_journal_cursor',
            where: 'user_id = ?',
            whereArgs: [userId],
          );
          throw StateError(
            'Journal sequence gap after $last (received $sequence); '
            'snapshot required.',
          );
        }
        last = sequence;
        final table = event['table_name'] as String;
        if (!_codecs.containsKey(table)) {
          throw StateError('Unsupported journal collection: $table');
        }
        final kind = event['change_kind'] as String;
        if (kind == 'invalidate') {
          invalidated.add(table);
        } else if (kind == 'upsert' || kind == 'delete') {
          final id = event['record_id'] as String?;
          if (id == null || id.isEmpty) throw StateError('Missing journal ID.');
          (records[table] ??= {})[id] = kind;
        } else {
          throw StateError('Unsupported journal change: $kind');
        }
      }

      for (final table in invalidated) {
        _checkUser();
        await snapshot(_codecs[table]!, last, generation);
      }
      final fetched = <String, Map<String, Map<String, dynamic>>>{};
      for (final entry in records.entries) {
        final codec = _codecs[entry.key]!;
        final ids = entry.value.entries
            .where((e) => e.value == 'upsert')
            .map((e) => e.key)
            .toList();
        if (ids.isEmpty) continue;
        final remote = await client
            .from(codec.table)
            .select()
            .inFilter(codec.key, ids)
            .timeout(const Duration(seconds: 8));
        fetched[entry.key] = {
          for (final row in remote) row[codec.key].toString(): row,
        };
      }

      _checkUser();
      await db.transaction((tx) async {
        _checkUser();
        for (final entry in records.entries) {
          final codec = _codecs[entry.key]!;
          for (final record in entry.value.entries) {
            await _merge.eventInTransaction(
              tx: tx,
              codec: codec,
              userId: userId,
              id: record.key,
              row: record.value == 'delete'
                  ? null
                  : fetched[entry.key]?[record.key],
              observedSequence: last,
              observedGeneration: generation,
            );
          }
        }
        _checkUser();
        await _saveCursor(tx, last, generation);
      });
      for (final table in records.keys) {
        notify(_codecs[table]!.modelType);
      }
      cursor = last;
      if (page.length < 100) break;
    }
    return true;
  }

  Future<void> _saveCursor(
    DatabaseExecutor executor,
    int sequence,
    int generation,
  ) async {
    await executor.insert('bicount_journal_cursor', {
      'user_id': userId,
      'sequence': sequence,
      'generation': generation,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
