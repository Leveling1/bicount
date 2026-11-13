import 'package:bicount/core/offline/offline_payload_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts equivalent numbers and timestamp formats', () {
    expect(
      remoteContainsSentPayload(
        {'amount': 10, 'date': '2026-11-07T10:00:00Z'},
        {'amount': 10.0, 'date': '2026-11-07T12:00:00+02:00', 'extra': true},
      ),
      isTrue,
    );
  });
  test('rejects missing and different fields', () {
    expect(remoteContainsSentPayload({'amount': 10}, {'amount': 11}), isFalse);
    expect(remoteContainsSentPayload({'amount': null}, {}), isFalse);
    expect(
      remoteContainsSentPayload(
        {'name': '2026-11-07T10:00:00Z'},
        {'name': '2026-11-07T12:00:00+02:00'},
      ),
      isFalse,
    );
  });
  test('compares nested structures without ignoring differences', () {
    expect(
      remoteContainsSentPayload(
        {
          'data': {
            'a': 1,
            'b': [2, 3],
          },
        },
        {
          'data': {
            'b': [2.0, 3],
            'a': 1,
          },
        },
      ),
      isTrue,
    );
    expect(
      remoteContainsSentPayload(
        {
          'data': [2, 3],
        },
        {
          'data': [3, 2],
        },
      ),
      isFalse,
    );
  });
}
