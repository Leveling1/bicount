part of 'wallet_bloc.dart';

sealed class WalletEvent {
  const WalletEvent();
}

final class WatchWallets extends WalletEvent {
  const WatchWallets();
}
