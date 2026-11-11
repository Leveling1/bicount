import 'dart:convert';

import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_remote_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('reads successive pages with an ascending cursor', () async {
    final requests = <Uri>[];
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        requests.add(request.url);
        final start = requests.length == 1 ? 0 : 500;
        final end = requests.length == 1 ? 500 : 502;
        return http.Response(
          jsonEncode([
            for (var i = start; i < end; i++)
              {'tid': i.toString().padLeft(4, '0')},
          ]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);

    final rows = await fetchOfflineRemoteSnapshot(
      client: client,
      codec: transactionModelCodec,
      isCurrentUser: () => true,
    );
    expect(rows, hasLength(502));
    expect(requests, hasLength(2));
    expect(requests.first.queryParameters['order'], startsWith('tid.asc'));
    expect(requests.last.queryParameters['tid'], 'gt.0499');
    expect(requests.last.queryParameters['order'], startsWith('tid.asc'));
  });
}
