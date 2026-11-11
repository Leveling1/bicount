import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_codecs.g.dart';

/// Reads every visible row in ascending key order; partial snapshots are never
/// returned after an account change or a failed page.
Future<List<Map<String, dynamic>>> fetchOfflineRemoteSnapshot({
  required SupabaseClient client,
  required OfflineCodec<dynamic> codec,
  required bool Function() isCurrentUser,
}) async {
  const pageSize = 500;
  String? lastId;
  final rows = <Map<String, dynamic>>[];
  while (isCurrentUser()) {
    final request = client.from(codec.table).select();
    final page = lastId == null
        ? await request
              .order(codec.key, ascending: true)
              .limit(pageSize)
              .timeout(const Duration(seconds: 8))
        : await request
              .gt(codec.key, lastId)
              .order(codec.key, ascending: true)
              .limit(pageSize)
              .timeout(const Duration(seconds: 8));
    rows.addAll(page);
    if (page.length < pageSize) break;
    final next = page.last[codec.key]?.toString();
    if (next == null || next.isEmpty || next == lastId) {
      throw StateError('Cannot page ${codec.table} without an advancing key');
    }
    lastId = next;
  }
  if (!isCurrentUser()) {
    throw StateError('Account changed during snapshot synchronization.');
  }
  return rows;
}
