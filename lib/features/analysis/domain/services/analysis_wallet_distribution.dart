import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/domain/services/wallet_balance_total.dart';

typedef AnalysisWalletBalance = ({WalletModel wallet, double? amount});

class AnalysisWalletDistribution {
  const AnalysisWalletDistribution._({
    required this.positive,
    required this.excluded,
    required this.total,
  });

  factory AnalysisWalletDistribution.fromBalances(
    List<WalletModel> wallets,
    List<WalletBalance> balances,
    CurrencyConfigEntity currency,
  ) {
    final byWallet = <String, List<WalletBalance>>{};
    for (final balance in balances) {
      (byWallet[balance.walletId] ??= []).add(balance);
    }

    final positive = <AnalysisWalletBalance>[];
    final excluded = <AnalysisWalletBalance>[];
    var total = 0.0;

    for (final wallet in wallets) {
      final amount = walletBalanceTotal(
        byWallet[wallet.id] ?? const [],
        currency,
      );
      if (amount == null || amount < 0) {
        excluded.add((wallet: wallet, amount: amount));
      } else if (amount > 0) {
        positive.add((wallet: wallet, amount: amount));
        total += amount;
      }
    }
    positive.sort((left, right) {
      final amount = right.amount!.compareTo(left.amount!);
      return amount == 0 ? left.wallet.id.compareTo(right.wallet.id) : amount;
    });

    return AnalysisWalletDistribution._(
      positive: positive,
      excluded: excluded,
      total: total,
    );
  }

  final List<AnalysisWalletBalance> positive;
  final List<AnalysisWalletBalance> excluded;
  final double total;
}
