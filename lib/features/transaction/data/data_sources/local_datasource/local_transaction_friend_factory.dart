import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

FriendsModel buildTransactionPlaceholderFriend({
  required String sid,
  required String ownerUid,
  required FriendsModel friend,
  required int transactionType,
}) {
  return FriendsModel(
    uid: null,
    sid: sid,
    fid: ownerUid,
    username: friend.username,
    email: friend.email,
    image: friend.image.isEmpty ? Constants.memojiDefault : friend.image,
    give: 0.0,
    receive: 0.0,
    relationType: FriendConst.getTypeOfFriend(transactionType),
  );
}
