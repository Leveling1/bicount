import 'package:bicount/core/constants/state_app.dart';
import 'package:equatable/equatable.dart';

class FriendShareEntity extends Equatable {
  const FriendShareEntity({
    required this.inviteId,
    required this.inviteCode,
    required this.inviteUrl,
    required this.createdAt,
    required this.expiresAt,
    this.sourceFriendSid,
    this.sourceFriendName,
    this.sourceFriendEmail,
    this.sourceFriendImage,
  });

  final String inviteId;
  final String inviteCode;
  final String inviteUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? sourceFriendSid;
  final String? sourceFriendName;
  final String? sourceFriendEmail;
  final String? sourceFriendImage;

  bool get isFriendProfileShare =>
      sourceFriendSid != null && sourceFriendSid!.isNotEmpty;

  String get subjectName {
    final value = sourceFriendName?.trim();
    if (value == null || value.isEmpty) {
      return 'profile';
    }
    return value;
  }

  @override
  List<Object?> get props => [
    inviteId,
    inviteCode,
    inviteUrl,
    createdAt,
    expiresAt,
    sourceFriendSid,
    sourceFriendName,
    sourceFriendEmail,
    sourceFriendImage,
  ];
}

class FriendInviteEntity extends Equatable {
  const FriendInviteEntity({
    required this.inviteId,
    required this.inviteCode,
    required this.senderUid,
    required this.senderName,
    required this.senderEmail,
    required this.senderImage,
    required this.statusId,
    required this.createdAt,
    required this.expiresAt,
    this.receiverUid,
    this.receiverName,
    this.sourceFriendSid,
    this.sourceFriendName,
    this.sourceFriendEmail,
    this.sourceFriendImage,
  });

  final String inviteId;
  final String inviteCode;
  final String senderUid;
  final String senderName;
  final String senderEmail;
  final String senderImage;
  final int statusId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? receiverUid;
  final String? receiverName;
  final String? sourceFriendSid;
  final String? sourceFriendName;
  final String? sourceFriendEmail;
  final String? sourceFriendImage;

  bool get isPending => AppFriendInviteState.isPending(statusId);

  bool get isFriendProfileInvite =>
      sourceFriendSid != null && sourceFriendSid!.isNotEmpty;

  String get linkedProfileName {
    final value = sourceFriendName?.trim();
    if (value == null || value.isEmpty) {
      return senderName;
    }
    return value;
  }

  @override
  List<Object?> get props => [
    inviteId,
    inviteCode,
    senderUid,
    senderName,
    senderEmail,
    senderImage,
    statusId,
    createdAt,
    expiresAt,
    receiverUid,
    receiverName,
    sourceFriendSid,
    sourceFriendName,
    sourceFriendEmail,
    sourceFriendImage,
  ];
}

class FriendHubEntity extends Equatable {
  const FriendHubEntity({
    this.activeShare,
    required this.sentInvites,
    required this.receivedInvites,
  });

  final FriendShareEntity? activeShare;
  final List<FriendInviteEntity> sentInvites;
  final List<FriendInviteEntity> receivedInvites;

  @override
  List<Object?> get props => [activeShare, sentInvites, receivedInvites];
}
