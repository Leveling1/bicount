import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/authentification/data/repositories/authentification_repository_impl.dart';
import 'package:bicount/features/settings/data/data_sources/local_datasource/settings_local_datasource.dart';
import 'package:bicount/features/settings/data/data_sources/remote_datasource/settings_remote_datasource.dart';
import 'package:bicount/features/settings/domain/entities/delete_account_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/settings_memoji_page_entity.dart';
import 'package:bicount/features/settings/domain/entities/pro_upgrade_request_entity.dart';
import 'package:bicount/features/settings/domain/entities/settings_profile_update_entity.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:bicount/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SettingsLocalDataSource localDataSource,
    required SettingsRemoteDataSource remoteDataSource,
    required AuthentificationRepositoryImpl authentificationRepository,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _authentificationRepository = authentificationRepository;

  final SettingsLocalDataSource _localDataSource;
  final SettingsRemoteDataSource _remoteDataSource;
  final AuthentificationRepositoryImpl _authentificationRepository;

  @override
  Future<AppThemePreference> readThemePreference() {
    return _localDataSource.readThemePreference();
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) {
    return _localDataSource.saveThemePreference(preference);
  }

  @override
  Future<void> updateProfile(SettingsProfileUpdateEntity update) {
    return _localDataSource.updateProfile(update);
  }

  @override
  Future<SettingsMemojiPageEntity?> readCachedMemojiPage() {
    return _localDataSource.readCachedMemojiPage();
  }

  @override
  Future<SettingsMemojiPageEntity> fetchMemojiPage({
    required int page,
    int limit = 20,
  }) async {
    try {
      final remotePage = await _remoteDataSource.fetchMemojiPage(
        page: page,
        limit: limit,
      );
      final mergedPage = page <= 1
          ? remotePage
          : _mergeMemojiPages(
              await _localDataSource.readCachedMemojiPage(),
              remotePage,
            );
      await _localDataSource.cacheMemojiPage(mergedPage);
      return mergedPage;
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(message: 'Unable to load memoji right now.');
    }
  }

  @override
  Future<void> requestProAccess(ProUpgradeRequestEntity request) async {
    try {
      await _remoteDataSource.requestProAccess(request);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(message: 'Unable to request Bicount Pro right now.');
    }
  }

  @override
  Future<void> signOut() async {
    final result = await _authentificationRepository.signOut();
    result.fold((failure) => throw failure, (_) => null);
  }

  @override
  Future<void> deleteAccount(DeleteAccountRequestEntity request) async {
    try {
      await _remoteDataSource.deleteAccount(request);
      await signOut();
    } on Failure {
      rethrow;
    } catch (e) {
      throw MessageFailure(message: 'Unable to delete your account right now.');
    }
  }

  SettingsMemojiPageEntity _mergeMemojiPages(
    SettingsMemojiPageEntity? cachedPage,
    SettingsMemojiPageEntity freshPage,
  ) {
    if (cachedPage == null || cachedPage.items.isEmpty) {
      return freshPage;
    }

    final mergedItems = [...cachedPage.items];
    final knownUrls = mergedItems.map((item) => item.url).toSet();
    for (final item in freshPage.items) {
      if (knownUrls.add(item.url)) {
        mergedItems.add(item);
      }
    }

    return freshPage.copyWith(items: mergedItems);
  }
}
