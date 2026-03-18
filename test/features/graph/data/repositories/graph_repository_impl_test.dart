import 'package:bicount/features/graph/data/data_sources/local_datasource/graph_local_datasource.dart';
import 'package:bicount/features/graph/data/repositories/graph_repository_impl.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGraphLocalDataSource implements GraphLocalDataSource {
  _FakeGraphLocalDataSource({
    required this.transactions,
    required this.subscriptions,
    required this.fundings,
  });

  final List<TransactionModel> transactions;
  final List<SubscriptionModel> subscriptions;
  final List<AccountFundingModel> fundings;

  @override
  Stream<List<AccountFundingModel>> watchAccountFundings() {
    return Stream.value(fundings);
  }

  @override
  Stream<List<SubscriptionModel>> watchSubscriptions() {
    return Stream.value(subscriptions);
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return Stream.value(transactions);
  }
}

void main() {
  test('graph repository aggregates cashflow and subscriptions', () async {
    final now = DateTime.now();
    final repository = GraphRepositoryImpl(
      _FakeGraphLocalDataSource(
        transactions: [
          TransactionModel(
            uid: 'u1',
            gtid: 'g1',
            name: 'Salary',
            type: 1,
            beneficiaryId: 'me',
            senderId: 'job',
            date: now.subtract(const Duration(days: 2)).toIso8601String(),
            note: '',
            amount: 1200,
            currency: 'USD',
            createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          ),
          TransactionModel(
            uid: 'u1',
            gtid: 'g2',
            name: 'Groceries',
            type: 2,
            beneficiaryId: 'store',
            senderId: 'me',
            date: now.subtract(const Duration(days: 1)).toIso8601String(),
            note: '',
            amount: 150,
            currency: 'USD',
            createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          ),
          TransactionModel(
            uid: 'u1',
            gtid: 'g3',
            name: 'Streaming',
            type: 4,
            beneficiaryId: 'netflix',
            senderId: 'me',
            date: now.toIso8601String(),
            note: '',
            amount: 20,
            currency: 'USD',
            createdAt: now.toIso8601String(),
          ),
        ],
        subscriptions: [
          SubscriptionModel(
            subscriptionId: 'sub1',
            sid: 'u1',
            title: 'Streaming',
            amount: 20,
            currency: 'USD',
            frequency: 1,
            startDate: now.subtract(const Duration(days: 10)).toIso8601String(),
            nextBillingDate: now.add(const Duration(days: 3)).toIso8601String(),
            status: 0,
          ),
        ],
        fundings: [
          AccountFundingModel(
            fundingId: 'fund1',
            sid: 'u1',
            amount: 50,
            currency: 'USD',
            category: 0,
            source: 'cash',
            date: now.subtract(const Duration(days: 4)).toIso8601String(),
            createdAt: now.subtract(const Duration(days: 4)).toIso8601String(),
          ),
        ],
      ),
    );

    final dashboard = await repository.watchDashboard(GraphPeriod.month30).first;

    expect(dashboard.inflow, 1250);
    expect(dashboard.outflow, 170);
    expect(dashboard.netFlow, 1080);
    expect(dashboard.activeSubscriptionCount, 1);
    expect(dashboard.monthlySubscriptionSpend, 20);
    expect(dashboard.dueSoonAmount, 20);
    expect(dashboard.expenseBreakdown.length, 2);
    expect(dashboard.cashflowPoints, isNotEmpty);
    expect(dashboard.upcomingSubscriptions.single.title, 'Streaming');
  });
}
