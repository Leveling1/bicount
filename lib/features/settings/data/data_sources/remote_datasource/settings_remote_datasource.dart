import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingsRemoteDataSource {
  Future<void> requestProAccess(ProUpgradeRequestEntity request);
  Future<void> deleteAccount(DeleteAccountRequestEntity request);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

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
