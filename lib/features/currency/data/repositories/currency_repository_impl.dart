import 'dart:async';

import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/currency/data/data_sources/local_datasource/currency_local_datasource.dart';
import 'package:bicount/features/currency/data/data_sources/remote_datasource/currency_remote_datasource.dart';
import 'package:bicount/features/currency/data/services/currency_record_history_service.dart';
import 'package:bicount/features/currency/data/services/currency_user_preference_service.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/entities/currency_quote_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'currency_repository_sync.dart';

class CurrencyRepositoryImpl {
  CurrencyRepositoryImpl({
    required this._localDataSource,
    required this._remoteDataSource,
    CurrencyRecordHistoryService? recordHistoryService,
    CurrencyUserPreferenceService? userPreferenceService,
  }) : _recordHistoryService =
           recordHistoryService ?? CurrencyRecordHistoryService(),
       _userPreferenceService =
           userPreferenceService ?? CurrencyUserPreferenceService() {
    _pushConfig(CurrencyConfigEntity.fallback());
    _sessionUserId = Supabase.instance.client.auth.currentUser?.id;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChanged,
    );
  }

  final CurrencyLocalDataSource _localDataSource;
  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyRecordHistoryService _recordHistoryService;
  final CurrencyUserPreferenceService _userPreferenceService;
  final BehaviorSubject<CurrencyConfigEntity> _configSubject =
      BehaviorSubject<CurrencyConfigEntity>();

  StreamSubscription<List<AppCurrencyEntity>>? _currencyCatalogSubscription;
  StreamSubscription<String?>? _userPreferenceSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  Future<void>? _hydrationInFlight;
  String? _sessionUserId;
  bool _disposed = false;

  Stream<CurrencyConfigEntity> watchConfig() => _configSubject.stream;

  CurrencyConfigEntity get currentConfig => _configSubject.value;

  Future<void> hydrate() =>
      _hydrationInFlight ??= _hydrateCurrencies().whenComplete(() {
        _hydrationInFlight = null;
      });

  Future<void> refreshCurrencies() async {
    final currencies = await _remoteDataSource.fetchCurrencies();
    await _onRemoteCurrenciesChanged(currencies);
  }

  Future<void> selectReferenceCurrency(String currencyCode) async {
    final normalizedCode = CurrencyConfigEntity.normalizeCode(currencyCode);
    try {
      await refreshCurrencies();
    } catch (_) {
      if (!currentConfig.containsCurrency(normalizedCode)) {
        rethrow;
      }
    }
    await ensureReferenceHistory(normalizedCode, includeStoredDates: true);
    await _userPreferenceService.persistCurrentUserReferenceCurrency(
      normalizedCode,
    );
    await _localDataSource.saveReferenceCurrencyCode(normalizedCode);
    _pushConfig(currentConfig.copyWith(referenceCurrencyCode: normalizedCode));
  }

  Future<void> ensureReferenceHistory(
    String currencyCode, {
    required bool includeStoredDates,
  }) async {
    final normalizedCode = CurrencyConfigEntity.normalizeCode(currencyCode);
    await _refreshLatestSnapshots({normalizedCode});

    if (!includeStoredDates) {
      return;
    }
    await _refreshReferenceHistory(normalizedCode);
  }

  Future<void> _refreshReferenceHistory(String normalizedCode) async {
    final rateDates = await _recordHistoryService.collectStoredRateDates();
    final historyCurrencyCodes = {
      normalizedCode,
      ...await _recordHistoryService.collectRecurringTransfertCurrencies(),
    }.map(CurrencyConfigEntity.normalizeCode).toSet();
    final missingCurrencyCodes = <String>{};
    final missingDates = <String>{};

    for (final code in historyCurrencyCodes) {
      final codeMissingDates = currentConfig.missingRateDates(
        currencyCode: code,
        rateDates: rateDates,
      );
      if (codeMissingDates.isEmpty) {
        continue;
      }

      missingCurrencyCodes.add(code);
      missingDates.addAll(codeMissingDates);
    }

    if (missingCurrencyCodes.isEmpty || missingDates.isEmpty) {
      return;
    }

    try {
      final snapshots = await _remoteDataSource.fetchSnapshotsForDates(
        currencyCodes: missingCurrencyCodes.toList(growable: false),
        rateDates: missingDates.toList(growable: false),
      );
      await _mergeSnapshots(snapshots);
    } catch (_) {
      // Keep the existing latest/cached snapshot support and allow the app
      // to convert with the history already available locally.
    }
  }

  Future<CurrencyQuoteEntity> resolveCreationQuote({
    required double amount,
    required String originalCurrencyCode,
  }) async {
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      originalCurrencyCode,
    );
    final referenceCurrencyCode = currentConfig.referenceCurrencyCode;
    final latestSnapshots = await _refreshLatestSnapshots({
      normalizedOriginal,
      referenceCurrencyCode,
    });
    final originalSnapshot = _resolveSnapshot(
      normalizedOriginal,
      latestSnapshots,
    );
    final referenceSnapshot = _resolveSnapshot(
      referenceCurrencyCode,
      latestSnapshots,
    );
    final amountCdf =
        normalizedOriginal == CurrencyConfigEntity.defaultReferenceCurrencyCode
        ? amount
        : amount * originalSnapshot.rateToCdf;

    return CurrencyQuoteEntity(
      referenceCurrencyCode: referenceCurrencyCode,
      convertedAmount:
          referenceCurrencyCode ==
              CurrencyConfigEntity.defaultReferenceCurrencyCode
          ? amountCdf
          : amountCdf / referenceSnapshot.rateToCdf,
      amountCdf: amountCdf,
      rateToCdf: originalSnapshot.rateToCdf,
      fxRateDate: originalSnapshot.normalizedRateDate,
      fxSnapshotId: originalSnapshot.snapshotId,
    );
  }

  Future<CurrencyQuoteEntity> resolveHistoricalQuote({
    required double amount,
    required String originalCurrencyCode,
    required String rateDate,
    String? referenceCurrencyCode,
  }) async {
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      originalCurrencyCode,
    );
    final normalizedReference = CurrencyConfigEntity.normalizeCode(
      referenceCurrencyCode ?? currentConfig.referenceCurrencyCode,
    );
    final normalizedRateDate = CurrencyConfigEntity.normalizeDate(rateDate);

    await _ensureSnapshotsForDate(
      currencyCodes: {normalizedOriginal, normalizedReference},
      rateDate: normalizedRateDate,
    );

    final originalSnapshot = _resolveSnapshotForDate(
      normalizedOriginal,
      normalizedRateDate,
    );
    final referenceSnapshot = _resolveSnapshotForDate(
      normalizedReference,
      normalizedRateDate,
    );
    final amountCdf =
        normalizedOriginal == CurrencyConfigEntity.defaultReferenceCurrencyCode
        ? amount
        : amount * originalSnapshot.rateToCdf;

    return CurrencyQuoteEntity(
      referenceCurrencyCode: normalizedReference,
      convertedAmount:
          normalizedReference ==
              CurrencyConfigEntity.defaultReferenceCurrencyCode
          ? amountCdf
          : amountCdf / referenceSnapshot.rateToCdf,
      amountCdf: amountCdf,
      rateToCdf: originalSnapshot.rateToCdf,
      fxRateDate: normalizedRateDate,
      fxSnapshotId: originalSnapshot.snapshotId,
    );
  }

  Future<void> _ensureSnapshotsForDate({
    required Set<String> currencyCodes,
    required String rateDate,
  }) async {
    final missingCodes = currencyCodes
        .map(CurrencyConfigEntity.normalizeCode)
        .where(
          (code) =>
              code != CurrencyConfigEntity.defaultReferenceCurrencyCode &&
              currentConfig.snapshotFor(
                    currencyCode: code,
                    rateDate: rateDate,
                  ) ==
                  null,
        )
        .toSet();
    if (missingCodes.isEmpty) {
      return;
    }

    final snapshots = await _remoteDataSource.fetchSnapshotsForDates(
      currencyCodes: missingCodes.toList(growable: false),
      rateDates: [rateDate],
    );
    await _mergeSnapshots(snapshots);

    final unresolvedCodes = missingCodes.where(
      (code) =>
          currentConfig.snapshotFor(currencyCode: code, rateDate: rateDate) ==
          null,
    );
    if (unresolvedCodes.isNotEmpty) {
      throw MessageFailure(
        message: 'Unable to load the exchange rate for this record date.',
      );
    }
  }

  ExchangeRateSnapshotEntity _resolveSnapshotForDate(
    String currencyCode,
    String rateDate,
  ) {
    final normalizedCode = CurrencyConfigEntity.normalizeCode(currencyCode);
    final snapshot = currentConfig.snapshotFor(
      currencyCode: normalizedCode,
      rateDate: rateDate,
    );
    if (snapshot != null) {
      return snapshot;
    }

    if (normalizedCode == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return ExchangeRateSnapshotEntity.cdf(rateDate);
    }

    throw MessageFailure(
      message: 'Unable to load the exchange rate for this record date.',
    );
  }

  ExchangeRateSnapshotEntity _resolveSnapshot(
    String currencyCode,
    List<ExchangeRateSnapshotEntity> remoteSnapshots,
  ) {
    final normalizedCode = CurrencyConfigEntity.normalizeCode(currencyCode);
    for (final snapshot in remoteSnapshots) {
      if (snapshot.currencyCode == normalizedCode) {
        return snapshot;
      }
    }

    final cachedSnapshot = currentConfig.latestSnapshot(normalizedCode);
    if (cachedSnapshot != null) {
      return cachedSnapshot;
    }

    if (normalizedCode == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      final referenceDate = remoteSnapshots.isEmpty
          ? DateTime.now().toIso8601String().substring(0, 10)
          : remoteSnapshots.first.normalizedRateDate;
      return ExchangeRateSnapshotEntity.cdf(referenceDate);
    }

    throw MessageFailure(
      message: 'Unable to load the latest exchange rates right now.',
    );
  }

  Future<void> _mergeSnapshots(
    List<ExchangeRateSnapshotEntity> snapshots,
  ) async {
    if (_disposed || snapshots.isEmpty) {
      return;
    }
    await _localDataSource.cacheSnapshots(snapshots);
    if (!_disposed) _pushConfig(currentConfig.withSnapshotUpserts(snapshots));
  }

  Future<void> _onRemoteCurrenciesChanged(
    List<AppCurrencyEntity> currencies,
  ) async {
    if (_disposed || currencies.isEmpty) {
      return;
    }
    await _localDataSource.cacheCurrencies(currencies);
    if (!_disposed) _pushConfig(currentConfig.copyWith(currencies: currencies));
  }

  Future<void> _onUserReferenceCurrencyChanged(String? currencyCode) async {
    final normalizedCode = CurrencyConfigEntity.normalizeCode(currencyCode);
    if (normalizedCode == currentConfig.referenceCurrencyCode) {
      return;
    }

    await _localDataSource.saveReferenceCurrencyCode(normalizedCode);
    _pushConfig(currentConfig.copyWith(referenceCurrencyCode: normalizedCode));

    try {
      await ensureReferenceHistory(normalizedCode, includeStoredDates: true);
    } catch (_) {}
  }

  Future<void> _rebindUserPreferenceStream() async {
    await _userPreferenceSubscription?.cancel();
    _userPreferenceSubscription = null;

    final userReferenceCurrency = await _userPreferenceService
        .readCurrentUserReferenceCurrency();
    if (userReferenceCurrency != null && userReferenceCurrency.isNotEmpty) {
      await _onUserReferenceCurrencyChanged(userReferenceCurrency);
    }

    _userPreferenceSubscription = _userPreferenceService
        .watchCurrentUserReferenceCurrency()
        .listen(
          (currencyCode) {
            unawaited(_safeOnUserReferenceCurrencyChanged(currencyCode));
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Currency preference realtime unavailable: $error');
          },
        );
  }

  Future<void> _safeRebindUserPreferenceStream() async {
    try {
      await _rebindUserPreferenceStream();
    } catch (error) {
      debugPrint('Currency preference stream rebind warning: $error');
    }
  }

  Future<void> _safeOnUserReferenceCurrencyChanged(String? currencyCode) async {
    try {
      await _onUserReferenceCurrencyChanged(currencyCode);
    } catch (error) {
      debugPrint('Currency preference update warning: $error');
    }
  }

  Future<void> _safeOnRemoteCurrenciesChanged(
    List<AppCurrencyEntity> currencies,
  ) async {
    try {
      await _onRemoteCurrenciesChanged(currencies);
    } catch (error) {
      debugPrint('Currency catalog sync warning: $error');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _authSubscription?.cancel();
    await _currencyCatalogSubscription?.cancel();
    await _userPreferenceSubscription?.cancel();
  }

  void _pushConfig(CurrencyConfigEntity config) {
    final safeConfig = config.copyWith(
      currencies: config.sortedCurrencies.isEmpty
          ? AppCurrencyEntity.fallbackCurrencies
          : config.currencies,
      referenceCurrencyCode:
          config.containsCurrency(config.referenceCurrencyCode)
          ? config.referenceCurrencyCode
          : CurrencyConfigEntity.defaultReferenceCurrencyCode,
    );
    NumberFormatUtils.configureCurrencies(
      currencies: safeConfig.sortedCurrencies,
      defaultCurrencyCode: safeConfig.referenceCurrencyCode,
    );
    _configSubject.add(safeConfig);
  }
}
