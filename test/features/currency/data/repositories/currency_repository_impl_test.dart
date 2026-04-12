import 'package:bicount/features/currency/data/data_sources/local_datasource/currency_local_datasource.dart';
import 'package:bicount/features/currency/data/data_sources/remote_datasource/currency_remote_datasource.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/data/services/currency_record_history_service.dart';
import 'package:bicount/features/currency/data/services/currency_user_preference_service.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeCurrencyLocalDataSource implements CurrencyLocalDataSource {
  final Map<String, ExchangeRateSnapshotEntity> _snapshots = {};

  @override
  Future<void> cacheCurrencies(List<AppCurrencyEntity> currencies) async {}

  @override
  Future<void> cacheSnapshots(
    Iterable<ExchangeRateSnapshotEntity> snapshots,
  ) async {
    for (final snapshot in snapshots) {
      _snapshots[snapshot.cacheKey] = snapshot;
    }
  }

  @override
  Future<List<AppCurrencyEntity>> readCachedCurrencies() async => const [];

  @override
  Future<Map<String, ExchangeRateSnapshotEntity>> readCachedSnapshots() async {
    return Map<String, ExchangeRateSnapshotEntity>.from(_snapshots);
  }

  @override
  Future<String?> readReferenceCurrencyCode() async => null;

  @override
  Future<void> saveReferenceCurrencyCode(String code) async {}
}

class _FakeCurrencyRemoteDataSource implements CurrencyRemoteDataSource {
  List<String> latestCodes = const [];
  List<String> historyCodes = const [];
  List<String> historyDates = const [];

  @override
  Future<List<AppCurrencyEntity>> fetchCurrencies() async => const [];

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchLatestSnapshotsForCodes(
    List<String> codes,
  ) async {
    latestCodes = List<String>.from(codes)..sort();
    if (latestCodes.length == 1 && latestCodes.first == 'CDF') {
      throw Exception('CDF latest snapshot is synthetic.');
    }

    return latestCodes
        .map(
          (code) => ExchangeRateSnapshotEntity(
            currencyCode: code,
            rateDate: '2026-04-12',
            rateToCdf: switch (code) {
              'EUR' => 3000,
              'USD' => 2000,
              _ => 1,
            },
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchSnapshotsForDates({
    required List<String> currencyCodes,
    required List<String> rateDates,
  }) async {
    historyCodes = List<String>.from(currencyCodes)..sort();
    historyDates = List<String>.from(rateDates)..sort();
    return [
      ExchangeRateSnapshotEntity(
        currencyCode: 'USD',
        rateDate: '2026-04-01',
        rateToCdf: 2000,
      ),
      ExchangeRateSnapshotEntity(
        currencyCode: 'EUR',
        rateDate: '2026-04-01',
        rateToCdf: 3000,
      ),
    ];
  }

  @override
  Stream<List<AppCurrencyEntity>> watchCurrencies() => const Stream.empty();
}

class _FakeCurrencyRecordHistoryService extends CurrencyRecordHistoryService {
  _FakeCurrencyRecordHistoryService({this.recurringCurrencies = const {'EUR'}});

  final Set<String> recurringCurrencies;

  @override
  Future<Set<String>> collectStoredRateDates() async => {'2026-04-01'};

  @override
  Future<Set<String>> collectRecurringTransfertCurrencies() async =>
      recurringCurrencies;
}

class _FakeCurrencyUserPreferenceService extends CurrencyUserPreferenceService {
  _FakeCurrencyUserPreferenceService()
    : super(client: Supabase.instance.client);

  @override
  Future<String?> readCurrentUserReferenceCurrency() async => null;

  @override
  Stream<String?> watchCurrentUserReferenceCurrency() => const Stream.empty();

  @override
  Future<void> persistCurrentUserReferenceCurrency(String currencyCode) async {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    try {
      Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    }
  });

  test(
    'ensureReferenceHistory loads recurring source currencies with the target history',
    () async {
      final remote = _FakeCurrencyRemoteDataSource();
      final repository = CurrencyRepositoryImpl(
        localDataSource: _FakeCurrencyLocalDataSource(),
        remoteDataSource: remote,
        recordHistoryService: _FakeCurrencyRecordHistoryService(),
        userPreferenceService: _FakeCurrencyUserPreferenceService(),
      );

      await repository.ensureReferenceHistory('USD', includeStoredDates: true);

      expect(remote.latestCodes, ['USD']);
      expect(remote.historyCodes, ['EUR', 'USD']);
      expect(remote.historyDates, ['2026-04-01']);
    },
  );

  test(
    'ensureReferenceHistory still loads recurring source currencies when reference is CDF',
    () async {
      final remote = _FakeCurrencyRemoteDataSource();
      final repository = CurrencyRepositoryImpl(
        localDataSource: _FakeCurrencyLocalDataSource(),
        remoteDataSource: remote,
        recordHistoryService: _FakeCurrencyRecordHistoryService(
          recurringCurrencies: const {'USD', 'EUR'},
        ),
        userPreferenceService: _FakeCurrencyUserPreferenceService(),
      );

      await repository.ensureReferenceHistory('CDF', includeStoredDates: true);

      expect(remote.latestCodes, ['CDF']);
      expect(remote.historyCodes, ['EUR', 'USD']);
      expect(remote.historyDates, ['2026-04-01']);
    },
  );
}
