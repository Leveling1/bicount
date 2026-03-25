import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/services/recurring_funding_schedule_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = RecurringFundingScheduleService();

  group('RecurringFundingScheduleService', () {
    test('normalizeDate supports form date values', () {
      final normalized = service.normalizeDate('19/03/2026');

      expect(normalized, startsWith('2026-03-19T00:00:00'));
    });

    test('nextOccurrence advances monthly schedules', () {
      final current = DateTime(2026, 3, 19);
      final next = service.nextOccurrence(current, Frequency.monthly);

      expect(next.year, 2026);
      expect(next.month, 4);
      expect(next.day, 19);
    });
  });
}
