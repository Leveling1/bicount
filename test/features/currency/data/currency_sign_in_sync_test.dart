import 'dart:convert';

import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/currency/data/data_sources/local_datasource/currency_local_datasource.dart';
import 'package:bicount/features/currency/data/data_sources/remote_datasource/currency_remote_datasource.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/data/services/currency_record_history_service.dart';
import 'package:bicount/features/currency/data/services/currency_user_preference_service.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Remote extends CurrencyRemoteDataSourceImpl {
  _Remote(super.client);

  @override
  Stream<List<AppCurrencyEntity>> watchCurrencies() => const Stream.empty();
}

class _Preferences extends CurrencyUserPreferenceService {
  @override
  Future<String?> readCurrentUserReferenceCurrency() async => null;

  @override
  Stream<String?> watchCurrentUserReferenceCurrency() => const Stream.empty();
}

class _History extends CurrencyRecordHistoryService {
  @override
  Future<Set<String>> collectStoredRateDates() async => {};

  @override
  Future<Set<String>> collectRecurringTransfertCurrencies() async => {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'sign-in caches available latest rates and server currency symbols',
    () async {
      SharedPreferences.setMockInitialValues({});
      final requests = <Uri>[];
      const rate = {
        'currency_code': 'USD',
        'rate_date': '2026-11-28',
        'rate_to_cdf': 2100,
      };
      await Supabase.initialize(
        url: 'http://localhost',
        publishableKey: 'test-key',
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request.url);
          final authenticated =
              Supabase.instance.client.auth.currentUser != null;
          final rows = authenticated
              ? switch (request.url.pathSegments.last) {
                  'currencies' => [
                    {'code': 'USD', 'symbol': r'US$'},
                    {'code': 'CAD', 'symbol': r'CA$'},
                  ],
                  'latest_exchange_rate_snapshots' => [rate],
                  'exchange_rate_snapshots' => [
                    {...rate, 'rate_date': '2026-05-01', 'rate_to_cdf': 2000},
                  ],
                  _ => throw StateError(
                    'Unexpected route: ${request.url.path}',
                  ),
                }
              : const [];
          return http.Response(
            jsonEncode(rows),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(Supabase.instance.dispose);

      final remote = _Remote(Supabase.instance.client);
      final local = CurrencyLocalDataSourceImpl();
      final repository = CurrencyRepositoryImpl(
        localDataSource: local,
        remoteDataSource: remote,
        recordHistoryService: _History(),
        userPreferenceService: _Preferences(),
      );
      addTearDown(repository.dispose);
      await repository.hydrate();
      expect(await local.readCachedSnapshots(), isEmpty);
      expect(NumberFormatUtils.resolveSymbol('USD'), 'USD');

      final refreshed = repository.watchConfig().firstWhere(
        (config) => config.latestRateToCdf('USD') == 2100,
      );
      String encodeSegment(Map<String, Object> data) =>
          base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
      final header = encodeSegment({'alg': 'HS256', 'typ': 'JWT'});
      final payload = encodeSegment({
        'exp':
            DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      await Supabase.instance.client.auth.recoverSession(
        jsonEncode({
          'access_token': '$header.$payload.test',
          'token_type': 'bearer',
          'user': {'id': 'test-user', 'aud': 'authenticated', 'created_at': ''},
        }),
      );

      final config = await refreshed.timeout(const Duration(seconds: 5));
      expect(config.latestRateToCdf('CAD'), isNull);
      expect(config.latestRateToCdf('CDF'), 1);
      expect(requests.last.path, endsWith('/latest_exchange_rate_snapshots'));
      expect(requests.last.queryParameters['currency_code'], contains('CAD'));
      expect(
        requests.last.queryParameters['currency_code'],
        isNot(contains('CDF')),
      );
      expect((await local.readCachedSnapshots()).values.single.rateToCdf, 2100);
      expect((await local.readCachedCurrencies()).first.symbol, r'US$');
      expect(NumberFormatUtils.resolveSymbol('USD'), r'US$');

      final history = await remote.fetchSnapshotsForDates(
        currencyCodes: ['USD'],
        rateDates: ['2026-05-01'],
      );
      expect(requests.last.path, endsWith('/exchange_rate_snapshots'));
      expect(history.single.rateToCdf, 2000);
    },
  );
}
