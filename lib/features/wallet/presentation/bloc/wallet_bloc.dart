import 'dart:async';

import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/wallet/domain/services/wallet_balance_total.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(
    this.repository, {
    Stream<Object?>? balanceChanges,
    CurrencyConfigEntity? currencyConfig,
    Stream<CurrencyConfigEntity>? currencyChanges,
  }) : super(
         WalletState(
           currencyConfig: currencyConfig ?? CurrencyConfigEntity.fallback(),
         ),
       ) {
    on<WatchWallets>(
      (_, emit) => emit.forEach(
        repository.watch(),
        onData: (wallets) {
          add(const RefreshWalletBalances());
          return state.copyWith(wallets: wallets);
        },
      ),
    );
    on<RefreshWalletBalances>((_, emit) async {
      final revision = ++_balanceRevision;
      try {
        final balances = await repository.balances();
        if (revision == _balanceRevision) {
          emit(state.copyWith(balances: balances));
        }
      } catch (_) {
        if (revision == _balanceRevision) {
          emit(
            WalletState(
              wallets: state.wallets,
              currencyConfig: state.currencyConfig,
            ),
          );
        }
      }
    });
    on<_WalletCurrencyChanged>((event, emit) {
      emit(state.copyWith(currencyConfig: event.config));
    });
    _balanceChanges = balanceChanges?.listen(
      (_) => add(const RefreshWalletBalances()),
    );
    _currencyChanges = currencyChanges?.listen(
      (config) => add(_WalletCurrencyChanged(config)),
    );
  }

  final WalletRepository repository;
  int _balanceRevision = 0;
  StreamSubscription<Object?>? _balanceChanges;
  StreamSubscription<CurrencyConfigEntity>? _currencyChanges;

  @override
  Future<void> close() async {
    await _balanceChanges?.cancel();
    await _currencyChanges?.cancel();
    await super.close();
  }
}
