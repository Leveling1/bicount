import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';

typedef WalletBalanceValuation = ({double? amount, String? missingRates});

/// Converts net native balances only when every required rate is available.
double? walletBalanceTotal(
  Iterable<WalletBalance> balances,
  CurrencyConfigEntity config, {
  String? walletId,
}) => valueWalletBalance(balances, config, walletId: walletId).amount;

WalletBalanceValuation valueWalletBalance(
  Iterable<WalletBalance> balances,
  CurrencyConfigEntity config, {
  String? walletId,
}) {
  final native = <String, int>{};
  for (final balance in balances) {
    if (walletId != null && balance.walletId != walletId) continue;
    final code = CurrencyConfigEntity.normalizeCode(balance.currency);
    native.update(
      code,
      (minor) => minor + balance.minor,
      ifAbsent: () => balance.minor,
    );
  }
  final target = CurrencyConfigEntity.normalizeCode(
    config.referenceCurrencyCode,
  );
  final targetRate = _validRate(config, target);
  final missingRates = <String>{};
  var total = 0.0;
  for (final entry in native.entries) {
    if (entry.value == 0) continue;
    final amount = entry.value / walletAmountScale;
    if (entry.key == target) {
      total += amount;
      continue;
    }
    final sourceRate = _validRate(config, entry.key);
    if (sourceRate == null) missingRates.add(entry.key);
    if (targetRate == null) missingRates.add(target);
    if (sourceRate != null && targetRate != null) {
      total += amount * sourceRate / targetRate;
    }
  }
  final missing = missingRates.isEmpty
      ? null
      : (missingRates.toList()..sort()).join(', ');
  return (
    amount: missing == null && total.isFinite ? total : null,
    missingRates: missing,
  );
}

double? _validRate(CurrencyConfigEntity config, String currency) {
  final rate = config.latestRateToCdf(currency);
  return rate != null && rate.isFinite && rate > 0 ? rate : null;
}
