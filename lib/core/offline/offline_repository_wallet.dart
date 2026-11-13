part of 'repository.dart';

extension OfflineRepositoryWallet on Repository {
  Future<void> assignTransactionWallet({
    required String tid,
    required bool isSender,
    required String walletId,
  }) async {
    if (!BackendEnvironment.isLocalPreproduction) {
      throw StateError('Wallets require local preproduction.');
    }
    final (uid, db) = await _writableDatabase();
    final codec = transactionModelCodec;
    final field = isSender ? 'sender_wallet_id' : 'beneficiary_wallet_id';
    final localRows = await db.query(
      codec.localTable,
      where: 'tid = ?',
      whereArgs: [tid],
    );
    final model = codec.fromLocal(localRows.single);
    final wallet = await db.query(
      walletModelCodec.localTable,
      where: 'wallet_id = ? AND owner_uid = ? AND archived_at IS NULL',
      whereArgs: [walletId, uid],
    );
    if (wallet.isEmpty && walletId != WalletModel.principalId(uid)) {
      throw StateError('Wallet is unavailable.');
    }
    final party = isSender ? model.senderId : model.beneficiaryId;
    if (party != uid) {
      final aliases = await db.query(
        'FriendsModel',
        where: 'sid = ? AND uid = ?',
        whereArgs: [party, uid],
        limit: 1,
      );
      if (aliases.isEmpty) throw StateError('Transaction side is unavailable.');
    }
    if (model.uid == uid) {
      final edited = codec.fromLocal({...localRows.single, field: walletId});
      await upsert(edited);
      return;
    }
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: codec.table,
        recordId: tid,
        action: 'transaction_wallet',
        payload: {
          'p_tid': tid,
          'p_is_sender': isSender,
          'p_wallet_id': walletId,
        },
      ),
      (tx) => tx.update(
        codec.localTable,
        {field: walletId},
        where: 'tid = ?',
        whereArgs: [tid],
      ),
    );
    notifyType(codec.modelType);
    _sync.schedule();
  }
}
