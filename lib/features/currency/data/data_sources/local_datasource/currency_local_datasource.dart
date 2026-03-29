import 'dart:convert';

import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CurrencyLocalDataSource {
  Future<String?> readReferenceCurrencyCode();
  Future<void> saveReferenceCurrencyCode(String code);
  Future<List<AppCurrencyEntity>> readCachedCurrencies();
  Future<void> cacheCurrencies(List<AppCurrencyEntity> currencies);
  Future<Map<String, ExchangeRateSnapshotEntity>> readCachedSnapshots();
  Future<void> cacheSnapshots(Iterable<ExchangeRateSnapshotEntity> snapshots);
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  static const _referenceCurrencyKey = 'bicount_reference_currency_v1';
  static const _currencyCatalogKey = 'bicount_currency_catalog_v1';
  static const _snapshotCacheKey = 'bicount_fx_snapshots_v1';

  @override
  Future<String?> readReferenceCurrencyCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_referenceCurrencyKey);
  }

  @override
  Future<void> saveReferenceCurrencyCode(String code) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_referenceCurrencyKey, code.toUpperCase());
  }

  @override
  Future<List<AppCurrencyEntity>> readCachedCurrencies() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_currencyCatalogKey);
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawValue) as List<dynamic>;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(AppCurrencyEntity.fromJson)
          .toList(growable: false);
    } catch (_) {
      await preferences.remove(_currencyCatalogKey);
      return const [];
    }
  }

  @override
  Future<void> cacheCurrencies(List<AppCurrencyEntity> currencies) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _currencyCatalogKey,
      jsonEncode(currencies.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<Map<String, ExchangeRateSnapshotEntity>> readCachedSnapshots() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_snapshotCacheKey);
    if (rawValue == null || rawValue.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          ExchangeRateSnapshotEntity.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      await preferences.remove(_snapshotCacheKey);
      return const {};
    }
  }

  @override
  Future<void> cacheSnapshots(
    Iterable<ExchangeRateSnapshotEntity> snapshots,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final existing = await readCachedSnapshots();
    final merged = Map<String, ExchangeRateSnapshotEntity>.from(existing);
    for (final snapshot in snapshots) {
      merged[snapshot.cacheKey] = snapshot;
    }

    await preferences.setString(
      _snapshotCacheKey,
      jsonEncode(merged.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }
}
