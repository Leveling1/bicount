import 'package:bicount/core/offline/offline_conflict_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final earlier = DateTime.utc(2026, 11, 7, 10);
  final later = DateTime.utc(2026, 11, 8, 10);
  ConflictTimeEstimate estimate(DateTime time, [int seconds = 0]) =>
      ConflictTimeEstimate(time, Duration(seconds: seconds));

  test('the newer server edit wins over the older offline edit', () {
    expect(
      compareConflictTimes(local: estimate(earlier), remote: estimate(later)),
      ConflictOrder.remoteLater,
    );
  });

  test('a later offline edit can win when both clocks are bounded', () {
    expect(
      compareConflictTimes(
        local: estimate(later, 60),
        remote: estimate(earlier),
      ),
      ConflictOrder.localLater,
    );
  });

  test('overlapping, equal or missing times do not pick a winner', () {
    expect(
      compareConflictTimes(
        local: estimate(earlier, 10),
        remote: estimate(earlier.add(const Duration(seconds: 10))),
      ),
      ConflictOrder.uncertain,
    );
    expect(
      compareConflictTimes(local: estimate(earlier), remote: estimate(earlier)),
      ConflictOrder.uncertain,
    );
    expect(
      compareConflictTimes(local: null, remote: estimate(later)),
      ConflictOrder.uncertain,
    );
  });

  test('negative clock uncertainty is invalid', () {
    expect(
      () => ConflictTimeEstimate(earlier, const Duration(seconds: -1)),
      throwsArgumentError,
    );
  });
}
