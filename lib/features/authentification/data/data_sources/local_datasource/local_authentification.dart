import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_service.dart';
import 'package:bicount/features/authentification/data/data_sources/local_datasource/authentification_local_datasource.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:brick_core/query.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../models/user.model.dart';

class LocalAuthentification implements AuthentificationLocalDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  String? get _currentUid => _supabaseClient.auth.currentUser?.id;

  @override
  Future<Either<Failure, void>> ensureCurrentUserProfile({
    String? emailHint,
  }) async {
    try {
      final uid = _currentUid;
      if (uid == null) {
        return Left(AuthenticationFailure(message: 'Authentication failure'));
      }

      final users = await Repository().get<UserModel>(
        query: Query(where: [Where.exact('uid', uid)]),
      );
      if (users.isNotEmpty) {
        return const Right(null);
      }

      final email =
          _supabaseClient.auth.currentUser?.email?.trim() ??
          emailHint?.trim() ??
          '';
      final username = _deriveUsername(email);

      await Repository().upsert<UserModel>(
        UserModel(
          uid: uid,
          image: Constants.memojiDefault,
          email: email,
          username: username,
          incomes: 0.0,
          expenses: 0.0,
          balance: 0.0,
          companyIncome: 0.0,
          personalIncome: 0.0,
          referenceCurrencyCode:
              CurrencyConfigEntity.defaultReferenceCurrencyCode,
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      try {
        await FlutterLocalNotificationsPlugin().cancelAll();
      } catch (error) {
        debugPrint('Local notification reset warning: $error');
      }
      await Repository().clearLocalSessionData();
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      await BicountHomeWidgetService.instance.resetToSignedOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Local sign out failed: $e'));
    }
  }

  String _deriveUsername(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return 'Bicount';
    }

    final localPart = normalizedEmail.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Bicount';
    }

    return localPart;
  }
}
