import 'dart:async';

import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository implements WalletRepository {
  final reads = StreamController<void>.broadcast();
  late Future<List<WalletBalance>> Function() load;

  @override
  Future<List<WalletBalance>> balances() {
    reads.add(null);
    return load();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'a failed balance read becomes unavailable instead of showing zero',
    () async {
      final repository = _Repository()
        ..load = () async => [(walletId: 'bank', currency: 'CDF', minor: 1000)];
      final bloc = WalletBloc(repository);
      addTearDown(bloc.close);
      addTearDown(repository.reads.close);
      final loaded = bloc.stream.firstWhere((state) => state.balances != null);
      bloc.add(const RefreshWalletBalances());
      expect((await loaded).totalFor('bank'), 10);

      repository.load = () async =>
          throw StateError('local storage unavailable');
      final unavailable = bloc.stream.firstWhere(
        (state) => state.balances == null,
      );
      bloc.add(const RefreshWalletBalances());
      expect((await unavailable).totalFor('bank'), isNull);
    },
  );

  test('an older read cannot replace more recent balances', () async {
    final first = Completer<List<WalletBalance>>();
    final second = Completer<List<WalletBalance>>();
    var calls = 0;
    final repository = _Repository()
      ..load = () => calls++ == 0 ? first.future : second.future;
    final bloc = WalletBloc(repository);
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
      await repository.reads.close();
    });
    var read = repository.reads.stream.first;
    bloc.add(const RefreshWalletBalances());
    await read;
    read = repository.reads.stream.first;
    bloc.add(const RefreshWalletBalances());
    await read;
    final loaded = bloc.stream.firstWhere((state) => state.balances != null);
    second.complete([(walletId: 'bank', currency: 'CDF', minor: 2000)]);
    expect((await loaded).totalFor('bank'), 20);
    first.complete([(walletId: 'bank', currency: 'CDF', minor: 1000)]);
    await bloc.close();
    expect(bloc.state.totalFor('bank'), 20);
  });
}
