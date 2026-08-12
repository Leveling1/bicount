import 'package:equatable/equatable.dart';

/// Everything a profile deletion is about to take away, counted before the
/// user confirms so the warning can name real numbers instead of a vague
/// "some data will be lost".
class FriendDeletionImpact extends Equatable {
  const FriendDeletionImpact({
    required this.transactionCount,
    required this.debtCount,
    required this.recurringCount,
  });

  const FriendDeletionImpact.empty()
    : transactionCount = 0,
      debtCount = 0,
      recurringCount = 0;

  final int transactionCount;
  final int debtCount;
  final int recurringCount;

  bool get isEmpty =>
      transactionCount == 0 && debtCount == 0 && recurringCount == 0;

  @override
  List<Object?> get props => [transactionCount, debtCount, recurringCount];
}

/// Which profile rows stopped being shared, so the caller can drop the copies
/// it can no longer read from the backend.
class FriendUnlinkResult extends Equatable {
  const FriendUnlinkResult({
    required this.unlinkedSids,
    required this.alreadyUnlinked,
  });

  final List<String> unlinkedSids;
  final bool alreadyUnlinked;

  @override
  List<Object?> get props => [unlinkedSids, alreadyUnlinked];
}
