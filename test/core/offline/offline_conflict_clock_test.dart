import 'package:bicount/core/offline/offline_conflict_clock.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test(
    'calibration bounds server time without trusting the wall clock offset',
    () {
      var elapsed = Duration.zero;
      var wall = DateTime.utc(2000);
      final clock = OfflineConflictClock(
        wallClock: () => wall,
        elapsed: () => elapsed,
      );
      expect(clock.estimate(), isNull);
      final start = clock.beginSample();
      elapsed += const Duration(milliseconds: 200);
      wall = wall.add(const Duration(milliseconds: 200));
      final server = DateTime.utc(2026, 11, 7, 10);
      clock.completeSample(start, server);
      elapsed += const Duration(minutes: 1);
      wall = wall.add(const Duration(minutes: 1));
      final estimate = clock.estimate()!;
      expect(
        estimate.earliest.isBefore(server.add(const Duration(minutes: 1))),
        isTrue,
      );
      expect(
        estimate.latest.isAfter(server.add(const Duration(minutes: 1))),
        isTrue,
      );
    },
  );

  test(
    'clock jumps and long request intervals make the estimate unavailable',
    () {
      var elapsed = Duration.zero;
      var wall = DateTime.utc(2026);
      final clock = OfflineConflictClock(
        wallClock: () => wall,
        elapsed: () => elapsed,
      );
      var start = clock.beginSample();
      elapsed += const Duration(seconds: 6);
      clock.completeSample(start, DateTime.utc(2026));
      expect(clock.estimate(), isNull);
      start = clock.beginSample();
      clock.completeSample(start, DateTime.utc(2026));
      wall = wall.add(const Duration(days: 1));
      expect(clock.estimate(), isNull);
    },
  );

  test('bounds survive local queue persistence', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    final earliest = DateTime.utc(2026, 11, 7, 10);
    final latest = earliest.add(const Duration(seconds: 5));
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'upsert',
        payload: {'tid': 'id'},
        editedEarliest: earliest,
        editedLatest: latest,
      ),
      (_) async {},
    );
    final restored = (await outbox.pending('u')).single;
    expect(restored.editedEarliest, earliest);
    expect(restored.editedLatest, latest);
  });
}
