import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this.repository) : super(const WalletState()) {
    on<WatchWallets>(
      (_, emit) => emit.forEach(
        repository.watch(),
        onData: (wallets) => WalletState(wallets: wallets),
      ),
    );
  }

  final WalletRepository repository;
}
