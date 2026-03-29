import 'dart:async';

import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyState extends Equatable {
  const CurrencyState({required this.config, this.isSyncing = false});

  const CurrencyState.initial()
    : config = const CurrencyConfigEntity(
        referenceCurrencyCode:
            CurrencyConfigEntity.defaultReferenceCurrencyCode,
        currencies: [],
        snapshotsByKey: {},
      ),
      isSyncing = false;

  final CurrencyConfigEntity config;
  final bool isSyncing;

  CurrencyState copyWith({CurrencyConfigEntity? config, bool? isSyncing}) {
    return CurrencyState(
      config: config ?? this.config,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [config, isSyncing];
}

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit(this._repository) : super(const CurrencyState.initial()) {
    _subscription = _repository.watchConfig().listen(
      (config) => emit(state.copyWith(config: config)),
    );
  }

  final CurrencyRepositoryImpl _repository;
  StreamSubscription<CurrencyConfigEntity>? _subscription;

  Future<void> hydrate() async {
    emit(state.copyWith(isSyncing: true));
    await _repository.hydrate();
    emit(state.copyWith(isSyncing: false, config: _repository.currentConfig));
  }

  Future<void> selectReferenceCurrency(String currencyCode) async {
    emit(state.copyWith(isSyncing: true));
    try {
      await _repository.selectReferenceCurrency(currencyCode);
      emit(state.copyWith(isSyncing: false, config: _repository.currentConfig));
    } catch (_) {
      emit(state.copyWith(isSyncing: false));
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
