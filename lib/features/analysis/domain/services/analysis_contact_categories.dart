import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

List<FriendsModel> analysisCategoryContacts(
  List<FriendsModel> friends,
  String? ownerUid,
) {
  if (ownerUid == null || ownerUid.isEmpty) return const [];
  return friends
      .where(
        (friend) =>
            friend.fid == ownerUid &&
            friend.uid != ownerUid &&
            friend.relationType == FriendConst.friend,
      )
      .toList()
    ..sort((left, right) {
      final name = left.username.toLowerCase().compareTo(
        right.username.toLowerCase(),
      );
      return name == 0 ? left.sid.compareTo(right.sid) : name;
    });
}

Map<String, FriendsModel> analysisContactAliases(
  AnalysisSourceData source,
  AnalysisChart chart,
) {
  final pinned = {
    for (final category in source.contactCategories)
      if (category.chart == chart && category.ownerUid == source.currentUserId)
        category.friendSid,
  };
  if (pinned.isEmpty) return const {};

  final contacts =
      analysisCategoryContacts(
          source.friends,
          source.currentUserId,
        ).where((friend) => pinned.contains(friend.sid)).toList()
        ..sort((left, right) => left.sid.compareTo(right.sid));
  final aliases = {for (final friend in contacts) friend.sid: friend};
  for (final friend in contacts) {
    final linkedUid = friend.uid;
    if (linkedUid != null && linkedUid.isNotEmpty) {
      aliases.putIfAbsent(linkedUid, () => friend);
    }
  }
  return aliases;
}
