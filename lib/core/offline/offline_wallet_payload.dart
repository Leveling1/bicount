import 'package:sqflite_common/sqlite_api.dart';

/// The shared records carry both pointers. An outgoing whole-record edit
/// includes only pointers this account is allowed to change.
Future<void> retainOwnWalletPointers(
  DatabaseExecutor db,
  String uid,
  Map<String, dynamic> payload,
) async {
  for (final side in ['sender', 'beneficiary', 'lender', 'borrower']) {
    final walletKey = '${side}_wallet_id';
    if (!payload.containsKey(walletKey)) continue;
    final party = payload['${side}_id'];
    if (party == uid) continue;
    final aliases = party == null
        ? const []
        : await db.query(
            'FriendsModel',
            columns: ['sid'],
            where: 'sid = ? AND uid = ?',
            whereArgs: [party, uid],
            limit: 1,
          );
    if (aliases.isEmpty) payload.remove(walletKey);
  }
}
