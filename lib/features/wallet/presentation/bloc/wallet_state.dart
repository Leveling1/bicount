part of 'wallet_bloc.dart';

final class WalletState {
  const WalletState({
    this.wallets = const [],
    this.balances,
    this.currencyConfig = const CurrencyConfigEntity(
      referenceCurrencyCode: 'CDF',
      currencies: [],
      snapshotsByKey: {},
    ),
  });

  final List<WalletModel> wallets;
  final List<WalletBalance>? balances;
  final CurrencyConfigEntity currencyConfig;

  String resolveTransactionWalletId(String ownerUid, String? requested) {
    if (requested != null &&
        (wallets.isEmpty || wallets.any((wallet) => wallet.id == requested))) {
      return requested;
    }
    return wallets.where((wallet) => wallet.isDefault).firstOrNull?.id ??
        wallets.firstOrNull?.id ??
        WalletModel.principalId(ownerUid);
  }

  double? totalFor(String? walletId) => balances == null
      ? null
      : walletBalanceTotal(balances!, currencyConfig, walletId: walletId);

  WalletState copyWith({
    List<WalletModel>? wallets,
    List<WalletBalance>? balances,
    CurrencyConfigEntity? currencyConfig,
  }) => WalletState(
    wallets: wallets ?? this.wallets,
    balances: balances ?? this.balances,
    currencyConfig: currencyConfig ?? this.currencyConfig,
  );
}
