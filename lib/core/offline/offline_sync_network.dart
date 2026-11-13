part of 'offline_sync.dart';

extension on OfflineSync {
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
    final project = Uri.parse(BackendEnvironment.projectUrl);
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
    request.headers.set('apikey', BackendEnvironment.anonKey);
    request.headers.set('authorization', 'Bearer $token');
    request.write(payload['body'] as String? ?? '');
    final response = await request.close().timeout(const Duration(seconds: 20));
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Queued request returned ${response.statusCode}');
    }
  }
}
