part of 'repository.dart';

extension OfflineRepositoryLocalData on Repository {
  Future<List<T>> localGet<T extends OfflineModel>({Query? query}) async {
    final codec = codecFor<T>();
    final clauses = <String>[];
    final args = <Object?>[];
    for (final condition in query?.where ?? const <Where>[]) {
      final column = codec.localColumns[condition.field] ?? condition.field;
      if (!codec.localColumns.values.contains(column)) {
        throw ArgumentError.value(condition.field, 'field');
      }
      clauses.add('"$column" ${condition.value == null ? 'IS NULL' : '= ?'}');
      if (condition.value != null) args.add(condition.value);
    }
    final rows = await (await database()).query(
      codec.localTable,
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args,
    );
    return rows.map((row) => codec.fromLocal(row)).toList(growable: false);
  }
}

class LocalSqliteProvider {
  Future<T> upsert<T extends OfflineModel>(
    T model, {
    Repository? repository,
    bool queue = true,
  }) async {
    final repo = repository ?? Repository();
    if (queue) return repo.upsert<T>(model);
    final codec = codecFor<T>();
    await (await repo.database()).insert(
      codec.localTable,
      codec.toLocal(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await repo.notifySubscriptionsWithLocalData<T>();
    return model;
  }

  Future<void> delete<T extends OfflineModel>(
    T model, {
    Repository? repository,
  }) async {
    final repo = repository ?? Repository();
    final codec = codecFor<T>();
    final id = codec.toLocal(model)[codec.localKey];
    await (await repo.database()).delete(
      codec.localTable,
      where: '"${codec.localKey}" = ?',
      whereArgs: [id],
    );
    await repo.notifySubscriptionsWithLocalData<T>();
  }
}
