import 'dart:convert';
import 'dart:io';

import 'package:bicount/core/constants/secrets.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/settings/data/models/settings_memoji_page_model.dart';
import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/settings_memoji_page_entity.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsMemojiPageEntity> fetchMemojiPage({
    required int page,
    int limit = 20,
  });
  Future<void> requestProAccess(ProUpgradeRequestEntity request);
  Future<void> deleteAccount(DeleteAccountRequestEntity request);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<SettingsMemojiPageEntity> fetchMemojiPage({
    required int page,
    int limit = 20,
  }) async {
    final requestUri = Uri.parse(
      '${Secrets.projectUrl}/functions/v1/get-memoji',
    ).replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );

    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(requestUri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set('apikey', Secrets.anonKey);

      final accessToken = _client.auth.currentSession?.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $accessToken',
        );
      }

      final response = await request.close();
      final payload = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MessageFailure(message: 'Unable to load memoji right now.');
      }

      final json = jsonDecode(payload) as Map<String, dynamic>;
      return SettingsMemojiPageModel.fromJson(json).toEntity();
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(message: 'Unable to load memoji right now.');
    } finally {
      httpClient.close(force: true);
    }
  }

  @override
  Future<void> requestProAccess(ProUpgradeRequestEntity request) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw MessageFailure(message: 'Authentication failure');
    }

    await _client.from('pro_upgrade_requests').upsert({
      'request_id': request.requestId,
      'user_uid': user.id,
      'contact_email': request.contactEmail,
      'organization_name': request.organizationName,
      'use_case': request.useCase,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'pending',
    });
  }

  @override
  Future<void> deleteAccount(DeleteAccountRequestEntity request) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw MessageFailure(message: 'Authentication failure');
    }

    await _client.from('account_deletion_requests').upsert({
      'request_id': request.requestId,
      'user_uid': user.id,
      'reason_code': request.reasonCode,
      'details': request.details,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'submitted',
    });

    await _client.functions.invoke(
      'delete-account',
      body: {
        'request_id': request.requestId,
        'user_uid': user.id,
        'reason_code': request.reasonCode,
        'details': request.details,
      },
    );
  }
}
