part of 'wallet_bloc.dart';

sealed class WalletEvent {
  const WalletEvent();
}

final class WatchWallets extends WalletEvent {
  const WatchWallets();
}

final class RefreshWalletBalances extends WalletEvent {
  const RefreshWalletBalances();
}

final class _WalletCurrencyChanged extends WalletEvent {
  const _WalletCurrencyChanged(this.config);
  final CurrencyConfigEntity config;
}
