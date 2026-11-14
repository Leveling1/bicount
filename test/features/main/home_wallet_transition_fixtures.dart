part of 'home_wallet_transition_test.dart';

class _MainRepository implements MainRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletRepository implements WalletRepository {
  @override
  Stream<List<WalletModel>> watch() => Stream.value(const [
    WalletModel(
      id: 'main',
      ownerUid: 'user',
      name: 'Principal',
      createdAt: '-',
      isDefault: true,
    ),
    WalletModel(
      id: 'bank',
      ownerUid: 'user',
      name: 'Bank',
      createdAt: '-',
      color: 2,
    ),
    WalletModel(
      id: 'cash',
      ownerUid: 'user',
      name: 'Cash',
      createdAt: '-',
      color: 4,
    ),
  ]);

  @override
  Future<List<WalletBalance>> balances() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
