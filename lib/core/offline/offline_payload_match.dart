/// Conservative comparison of sent fields with a row read under RLS.
/// Timestamp normalization is limited to explicitly identified timestamp keys.
bool remoteContainsSentPayload(
  Map<String, Object?> sent,
  Map<String, dynamic> remote, {
  Set<String> timestampFields = const {'date', 'created_at', 'updated_at'},
}) {
  return sent.entries.every((entry) {
    if (!remote.containsKey(entry.key)) return false;
    return _equal(
      entry.value,
      remote[entry.key],
      timestampFields.contains(entry.key),
    );
  });
}

bool _equal(Object? left, Object? right, bool timestamp) {
  if (left == right) return true;
  if (timestamp && left is String && right is String) {
    final first = DateTime.tryParse(left);
    final second = DateTime.tryParse(right);
    return first != null && second != null && first.toUtc() == second.toUtc();
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_equal(left[index], right[index], false)) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    return left.length == right.length &&
        left.keys.every(
          (key) =>
              right.containsKey(key) && _equal(left[key], right[key], false),
        );
  }
  return false;
}
