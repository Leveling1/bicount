import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/wallet/data/data_sources/local_datasource/wallet_balance_store.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl() : _repository = Repository();

  final Repository _repository;

  WalletModel principal(String uid) => WalletModel(
    id: WalletModel.principalId(uid),
    ownerUid: uid,
    name: 'Principal',
    createdAt: '',
    isDefault: true,
  );

  @override
  Stream<List<WalletModel>> watch() {
    final uid = _repository.currentUserId;
    if (uid == null) return Stream.value(const []);
    return _repository.subscribeToRealtime<WalletModel>().map((wallets) {
      final own = wallets.where((wallet) => wallet.ownerUid == uid).toList();
      if (own.every((wallet) => !wallet.isDefault)) own.add(principal(uid));
      return own..sort(
        (a, b) => a.isDefault == b.isDefault
            ? a.name.compareTo(b.name)
            : a.isDefault
            ? -1
            : 1,
      );
    });
  }

  @override
  Future<List<WalletBalance>> balances() async =>
      readWalletBalances(await _repository.database());

  @override
  Future<void> assignTransaction({
    required String tid,
    required bool isSender,
    required String walletId,
  }) => _repository.assignTransactionWallet(
    tid: tid,
    isSender: isSender,
    walletId: walletId,
  );

  @override
  Future<void> save({
    WalletModel? existing,
    required String name,
    required WalletKind kind,
    WalletCardNetwork? network,
    required int icon,
    required int color,
    bool archived = false,
  }) async {
    final uid = _repository.currentUserId;
    if (uid == null ||
        (existing != null && existing.ownerUid != uid) ||
        (existing?.isDefault == true &&
            (archived || existing!.createdAt.isEmpty))) {
      throw StateError('Wallet is unavailable.');
    }
    await _repository.upsert(
      WalletModel(
        id: existing?.id ?? const Uuid().v4(),
        ownerUid: uid,
        name: name.trim(),
        kind: kind,
        cardNetwork: kind == WalletKind.card ? network : null,
        icon: icon,
        color: color,
        isDefault: existing?.isDefault ?? false,
        createdAt:
            existing?.createdAt ?? DateTime.now().toUtc().toIso8601String(),
        archivedAt: archived ? DateTime.now().toUtc().toIso8601String() : null,
      ),
      isCreation: existing == null,
    );
  }

  @override
  Future<void> transfer({
    required WalletModel from,
    required WalletModel to,
    required double amount,
    required String currency,
    required String title,
  }) async {
    final uid = _repository.currentUserId;
    if (uid == null ||
        from.ownerUid != uid ||
        to.ownerUid != uid ||
        from.id == to.id ||
        from.archivedAt != null ||
        to.archivedAt != null ||
        !amount.isFinite ||
        amount <= 0) {
      throw ArgumentError('Invalid wallet transfer.');
    }
    final timestamp = DateTime.now().toUtc().toIso8601String();
    await _repository.upsert(
      TransactionModel(
        uid: uid,
        gtid: const Uuid().v4(),
        name: title,
        type: TransactionTypes.walletTransferCode,
        beneficiaryId: uid,
        senderId: uid,
        senderWalletId: from.id,
        beneficiaryWalletId: to.id,
        date: timestamp,
        note: '',
        amount: amount,
        currency: currency,
        category: Constants.personal,
        createdAt: timestamp,
      ),
      isCreation: true,
    );
  }
}
