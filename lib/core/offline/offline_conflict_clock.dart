import 'offline_conflict_order.dart';

/// Session-only clock calibration. An absent or inconsistent sample is unknown.
class OfflineConflictClock {
  OfflineConflictClock({
    DateTime Function()? wallClock,
    Duration Function()? elapsed,
  }) : _wallClock = wallClock ?? DateTime.now,
       _elapsed = elapsed ?? _defaultElapsed;

  static final Stopwatch _stopwatch = Stopwatch()..start();
  static Duration _defaultElapsed() => _stopwatch.elapsed;
  static final OfflineConflictClock instance = OfflineConflictClock();

  final DateTime Function() _wallClock;
  final Duration Function() _elapsed;
  DateTime? _serverAtSample;
  DateTime? _wallAtResponse;
  Duration? _elapsedAtResponse;
  Duration? _roundTrip;

  Duration beginSample() => _elapsed();

  void completeSample(Duration started, DateTime serverTime) {
    final ended = _elapsed();
    final roundTrip = ended - started;
    if (roundTrip.isNegative || roundTrip > const Duration(seconds: 5)) return;
    _serverAtSample = serverTime.toUtc();
    _wallAtResponse = _wallClock().toUtc();
    _elapsedAtResponse = ended;
    _roundTrip = roundTrip;
  }

  ConflictTimeEstimate? estimate() {
    final server = _serverAtSample;
    final wall = _wallAtResponse;
    final anchor = _elapsedAtResponse;
    final roundTrip = _roundTrip;
    if (server == null || wall == null || anchor == null || roundTrip == null) {
      return null;
    }
    final elapsed = _elapsed() - anchor;
    if (elapsed.isNegative) return null;
    final wallElapsed = _wallClock().toUtc().difference(wall);
    if ((wallElapsed - elapsed).abs() > const Duration(seconds: 2)) return null;
    // Allow ten seconds of drift per day plus two seconds of measurement slack.
    final drift = Duration(
      microseconds: (elapsed.inMicroseconds / 8640).ceil(),
    );
    return ConflictTimeEstimate(
      server.add(elapsed + roundTrip ~/ 2),
      const Duration(seconds: 2) + drift + roundTrip ~/ 2,
    );
  }
}
