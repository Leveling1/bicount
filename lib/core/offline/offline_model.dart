/// Marker for records stored locally before network synchronization.
abstract class OfflineModel {
  const OfflineModel();
}

enum OfflineReadPolicy { localOnly, localThenRemote }

class Where {
  const Where.exact(this.field, this.value);

  final String field;
  final Object? value;
}

class Query {
  const Query({this.where = const []});

  final List<Where> where;
}
