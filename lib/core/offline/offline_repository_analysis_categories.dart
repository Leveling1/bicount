part of 'repository.dart';

extension OfflineAnalysisCategories on Repository {
  Future<void> saveAnalysisCategories({
    required String ownerUid,
    required Iterable<AnalysisContactCategory> added,
    required Iterable<AnalysisContactCategory> removed,
  }) async {
    final (uid, db) = await _writableDatabase();
    if (uid != ownerUid) throw StateError('The analysis account changed.');

    final codec = analysisContactCategoryCodec;
    OfflineOperation operation(
      AnalysisContactCategory category,
      String action,
    ) {
      if (category.ownerUid != uid) {
        throw StateError('The analysis category belongs to another account.');
      }
      return OfflineOperation(
        userId: uid,
        collection: codec.table,
        recordId: category.id,
        action: action,
        payload: action == 'delete'
            ? {codec.key: category.id}
            : category.toRow(),
      );
    }

    final operations = [
      ...removed.map((category) => operation(category, 'delete')),
      ...added.map((category) => operation(category, 'upsert')),
    ];
    if (operations.isEmpty) return;
    await OfflineOutbox(db).commitBatch(operations, (tx, operation) async {
      if (operation.action == 'delete') {
        await tx.delete(
          codec.localTable,
          where: '"${codec.localKey}" = ?',
          whereArgs: [operation.recordId],
        );
      } else {
        await tx.insert(
          codec.localTable,
          operation.payload,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    notifyType(AnalysisContactCategory);
    _sync.schedule();
  }
}
