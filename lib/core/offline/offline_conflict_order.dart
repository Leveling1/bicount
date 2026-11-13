/// An estimated modification time with a bound on its clock error.
/// Unknown or unbounded clock errors must not be represented by this type.
class ConflictTimeEstimate {
  ConflictTimeEstimate(DateTime time, this.maxError) : time = time.toUtc() {
    if (maxError.isNegative) throw ArgumentError.value(maxError, 'maxError');
  }

  final DateTime time;
  final Duration maxError;

  DateTime get earliest => time.subtract(maxError);
  DateTime get latest => time.add(maxError);
}

enum ConflictOrder { localLater, remoteLater, uncertain }

/// Orders only changes whose possible time ranges do not overlap.
/// A missing estimate or overlapping intervals cannot establish a winner.
ConflictOrder compareConflictTimes({
  required ConflictTimeEstimate? local,
  required ConflictTimeEstimate? remote,
}) {
  if (local == null || remote == null) return ConflictOrder.uncertain;
  if (local.earliest.isAfter(remote.latest)) return ConflictOrder.localLater;
  if (remote.earliest.isAfter(local.latest)) return ConflictOrder.remoteLater;
  return ConflictOrder.uncertain;
}
