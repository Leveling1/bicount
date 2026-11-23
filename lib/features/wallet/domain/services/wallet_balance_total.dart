import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';

/// Converts net native balances only when every required rate is available.
double? walletBalanceTotal(
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
  var total = 0.0;
  for (final entry in native.entries) {
    if (entry.value == 0) continue;
    final amount = entry.value / walletAmountScale;
    if (entry.key == target) {
      total += amount;
      continue;
    }
    final sourceRate = config.latestRateToCdf(entry.key);
    final targetRate = config.latestRateToCdf(target);
    if (sourceRate == null ||
        !sourceRate.isFinite ||
        sourceRate <= 0 ||
        targetRate == null ||
        !targetRate.isFinite ||
        targetRate <= 0) {
      return null;
    }
    total += amount * sourceRate / targetRate;
  }
  return total.isFinite ? total : null;
}
