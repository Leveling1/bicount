import 'package:sqflite_common/sqlite_api.dart';

/// Attributes an old shared database only when its stored owner IDs agree.
Future<bool> legacyDatabaseBelongsTo(
  DatabaseFactory factory,
  String path,
  String userId,
) async {
  if (!await factory.databaseExists(path)) return false;
  final db = await factory.openDatabase(
    path,
    options: OpenDatabaseOptions(readOnly: true),
  );
  try {
    try {
      final profiles = await db.rawQuery(
        'SELECT DISTINCT uid FROM UserModel '
        'WHERE uid IS NOT NULL LIMIT 3',
      );
      if (profiles.isNotEmpty) {
        return profiles.length == 1 && profiles.single['uid'] == userId;
      }
    } catch (_) {}
    const ownerColumns = <String, String>{
      'TransactionModel': 'uid',
      'RecurringFundingModel': 'uid',
      'RecurringTransfertModel': 'uid',
      'DebtModel': 'created_by',
    };
    final owners = <String>{};
    for (final entry in ownerColumns.entries) {
      try {
        final rows = await db.rawQuery(
          'SELECT DISTINCT "${entry.value}" '
          'FROM "${entry.key}" WHERE "${entry.value}" IS NOT NULL '
          'LIMIT 3',
        );
        owners.addAll(
          rows
              .map((row) => row[entry.value]?.toString())
              .whereType<String>()
              .where((value) => value.isNotEmpty),
        );
      } catch (_) {
        // Older releases may lack a table or column.
      }
    }
    if (owners.isEmpty) {
      try {
        final rows = await db.rawQuery(
          'SELECT DISTINCT fid FROM FriendsModel '
          'WHERE fid IS NOT NULL LIMIT 3',
        );
        owners.addAll(
          rows
              .map((row) => row['fid']?.toString())
              .whereType<String>()
              .where((value) => value.isNotEmpty),
        );
      } catch (_) {}
    }
    return owners.length == 1 && owners.single == userId;
  } finally {
    await db.close();
  }
}
