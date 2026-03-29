import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CurrencyRemoteDataSource {
  Future<List<AppCurrencyEntity>> fetchCurrencies();
  Stream<List<AppCurrencyEntity>> watchCurrencies();
  Future<List<ExchangeRateSnapshotEntity>> fetchLatestSnapshotsForCodes(
    List<String> codes,
  );
  Future<List<ExchangeRateSnapshotEntity>> fetchSnapshotsForDates({
    required List<String> currencyCodes,
    required List<String> rateDates,
  });
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  CurrencyRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AppCurrencyEntity>> fetchCurrencies() async {
    final rows = await _client
        .from('currencies')
        .select('code, name, symbol, decimals, display_order, is_active')
        .eq('is_active', true)
        .order('display_order');

    return _parseCurrencies(rows);
  }

  @override
  Stream<List<AppCurrencyEntity>> watchCurrencies() {
    return _client
        .from('currencies')
        .stream(primaryKey: ['code'])
        .eq('is_active', true)
        .order('display_order')
        .map(_parseCurrencies);
  }

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchLatestSnapshotsForCodes(
    List<String> codes,
  ) async {
    final requestedCodes = _normalizeCodes(codes);
    if (requestedCodes.isEmpty) {
      return const [];
    }

    final rows = await _client
        .from('exchange_rate_snapshots')
        .select(
          'snapshot_id, currency_code, rate_date, rate_to_cdf, provider, source_url, created_at',
        )
        .inFilter('currency_code', requestedCodes.toList())
        .order('rate_date', ascending: false);

    final snapshotsByCode = <String, ExchangeRateSnapshotEntity>{};
    for (final row in rows as List<dynamic>) {
      final snapshot = ExchangeRateSnapshotEntity.fromJson(
        row as Map<String, dynamic>,
      );
      snapshotsByCode.putIfAbsent(snapshot.currencyCode, () => snapshot);
      if (snapshotsByCode.length == requestedCodes.length) {
        break;
      }
    }

    if (snapshotsByCode.length != requestedCodes.length) {
      throw MessageFailure(
        message: 'Unable to load the latest exchange rates right now.',
      );
    }

    return snapshotsByCode.values.toList(growable: false);
  }

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchSnapshotsForDates({
    required List<String> currencyCodes,
    required List<String> rateDates,
  }) async {
    final requestedCodes = _normalizeCodes(currencyCodes);
    final requestedDates = rateDates
        .map((item) => item.length >= 10 ? item.substring(0, 10) : item)
        .toSet();
    if (requestedCodes.isEmpty || requestedDates.isEmpty) {
      return const [];
    }

    final rows = await _client
        .from('exchange_rate_snapshots')
        .select(
          'snapshot_id, currency_code, rate_date, rate_to_cdf, provider, source_url, created_at',
        )
        .inFilter('currency_code', requestedCodes.toList())
        .inFilter('rate_date', requestedDates.toList())
        .order('rate_date');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ExchangeRateSnapshotEntity.fromJson)
        .toList(growable: false);
  }

  List<AppCurrencyEntity> _parseCurrencies(List<dynamic> rows) {
    return rows
        .cast<Map<String, dynamic>>()
        .map(AppCurrencyEntity.fromJson)
        .toList(growable: false);
  }

  Set<String> _normalizeCodes(List<String> values) {
    return values
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty && value != 'CDF')
        .toSet();
  }
}
