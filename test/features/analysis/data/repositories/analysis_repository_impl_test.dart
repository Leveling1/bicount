import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/currency/data/data_sources/local_datasource/currency_local_datasource.dart';
import 'package:bicount/features/currency/data/data_sources/remote_datasource/currency_remote_datasource.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/currency/domain/entities/exchange_rate_snapshot_entity.dart';
import 'package:bicount/features/analysis/data/data_sources/local_datasource/analysis_local_datasource.dart';
import 'package:bicount/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAnalysisLocalDataSource implements AnalysisLocalDataSource {
  _FakeAnalysisLocalDataSource({required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return Stream.value(transactions);
  }
}

class _FakeCurrencyLocalDataSource implements CurrencyLocalDataSource {
  @override
  Future<void> cacheCurrencies(List<AppCurrencyEntity> currencies) async {}

  @override
  Future<void> cacheSnapshots(
    Iterable<ExchangeRateSnapshotEntity> snapshots,
  ) async {}

  @override
  Future<List<AppCurrencyEntity>> readCachedCurrencies() async => const [];

  @override
  Future<Map<String, ExchangeRateSnapshotEntity>> readCachedSnapshots() async {
    return const {};
  }

  @override
  Future<String?> readReferenceCurrencyCode() async => null;

  @override
  Future<void> saveReferenceCurrencyCode(String code) async {}
}

class _FakeCurrencyRemoteDataSource implements CurrencyRemoteDataSource {
  @override
  Future<List<AppCurrencyEntity>> fetchCurrencies() async => const [];

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchLatestSnapshotsForCodes(
    List<String> codes,
  ) async {
    return const [];
  }

  @override
  Future<List<ExchangeRateSnapshotEntity>> fetchSnapshotsForDates({
    required List<String> currencyCodes,
    required List<String> rateDates,
  }) async {
    return const [];
  }

  @override
  Stream<List<AppCurrencyEntity>> watchCurrencies() => const Stream.empty();
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

  test('analysis repository aggregates cashflow and breakdowns', () async {
    final now = DateTime.now();
    final twoDaysAgo = now.subtract(const Duration(days: 2)).toIso8601String();
    final oneDayAgo = now.subtract(const Duration(days: 1)).toIso8601String();
    final today = now.toIso8601String();
    final currencyRepository = CurrencyRepositoryImpl(
      localDataSource: _FakeCurrencyLocalDataSource(),
      remoteDataSource: _FakeCurrencyRemoteDataSource(),
    );
    final repository = AnalysisRepositoryImpl(
      _FakeAnalysisLocalDataSource(
        transactions: [
          TransactionModel(
            uid: 'u1',
            gtid: 'g1',
            name: 'Salary',
            type: TransactionTypes.incomeCode,
            beneficiaryId: 'me',
            senderId: 'job',
            date: twoDaysAgo,
            note: '',
            amount: 1200,
            currency: 'USD',
            createdAt: twoDaysAgo,
          ),
          TransactionModel(
            uid: 'u1',
            gtid: 'g2',
            name: 'Cash deposit',
            type: TransactionTypes.incomeCode,
            beneficiaryId: 'me',
            senderId: 'cash',
            date: oneDayAgo,
            note: '',
            amount: 50,
            currency: 'USD',
            createdAt: oneDayAgo,
          ),
          TransactionModel(
            uid: 'u1',
            gtid: 'g3',
            name: 'Groceries',
            type: TransactionTypes.expenseCode,
            beneficiaryId: 'store',
            senderId: 'me',
            date: today,
            note: '',
            amount: 150,
            currency: 'USD',
            createdAt: today,
          ),
          TransactionModel(
            uid: 'u1',
            gtid: 'g4',
            name: 'Streaming',
            type: TransactionTypes.othersCode,
            beneficiaryId: 'netflix',
            senderId: 'me',
            date: today,
            note: '',
            amount: 20,
            currency: 'USD',
            createdAt: today,
          ),
        ],
      ),
      currencyRepository: currencyRepository,
    );

    final dashboard = await repository
        .watchDashboard(AnalysisPeriod.month30)
        .first;

    expect(dashboard.inflow, 1250);
    expect(dashboard.outflow, 170);
    expect(dashboard.netFlow, 1080);
    expect(dashboard.displayCurrencyCode, 'CDF');
    expect(dashboard.incomeBreakdown, const [
      AnalysisBreakdownItem(label: 'Income', value: 1250),
    ]);
    expect(dashboard.expenseBreakdown.length, 2);
    expect(
      dashboard.expenseBreakdown[0],
      const AnalysisBreakdownItem(label: 'Expenses', value: 150),
    );
    expect(
      dashboard.expenseBreakdown[1],
      const AnalysisBreakdownItem(label: 'Other', value: 20),
    );
    expect(dashboard.cashflowPoints, isNotEmpty);
  });
}
