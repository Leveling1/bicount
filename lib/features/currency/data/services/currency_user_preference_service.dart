import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CurrencyUserPreferenceService {
  CurrencyUserPreferenceService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _currentUid => _client.auth.currentUser?.id;

  Future<String?> readCurrentUserReferenceCurrency() async {
    final uid = _currentUid;
    if (uid == null) {
      return null;
    }

    final localValue = await _readLocalReferenceCurrency(uid);
    if (localValue != null) {
      return localValue;
    }

    try {
      final response = await _client
          .from('users')
          .select('reference_currency_code')
          .eq('uid', uid)
          .maybeSingle();
      final value = response?['reference_currency_code']?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }

  Stream<String?> watchCurrentUserReferenceCurrency() {
    final uid = _currentUid;
    if (uid == null) {
      return const Stream.empty();
    }

    return _client.from('users').stream(primaryKey: ['uid']).eq('uid', uid).map(
      (users) {
        if (users.isEmpty) {
          return null;
        }
        final value = users.first['reference_currency_code']?.toString().trim();
        return value == null || value.isEmpty ? null : value;
      },
    ).distinct();
  }

  Future<void> persistCurrentUserReferenceCurrency(String currencyCode) async {
    final uid = _currentUid;
    if (uid == null) {
      return;
    }

    await _client
        .from('users')
        .update({'reference_currency_code': currencyCode})
        .eq('uid', uid);

    final users = await Repository().get<UserModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('uid', uid)]),
    );
    if (users.isEmpty) {
      return;
    }

    final currentUser = users.first;
    await Repository().upsert<UserModel>(
      UserModel(
        uid: currentUser.uid,
        image: currentUser.image,
        username: currentUser.username,
        email: currentUser.email,
        incomes: currentUser.incomes,
        expenses: currentUser.expenses,
        balance: currentUser.balance,
        companyIncome: currentUser.companyIncome,
        personalIncome: currentUser.personalIncome,
        referenceCurrencyCode: currencyCode,
      ),
    );
  }

  Future<String?> _readLocalReferenceCurrency(String uid) async {
    final users = await Repository().get<UserModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('uid', uid)]),
    );
    if (users.isEmpty) {
      return null;
    }

    final value = users.first.referenceCurrencyCode?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
