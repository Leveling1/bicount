import 'package:equatable/equatable.dart';

enum FriendInviteStatus { pending, accepted, rejected, expired }

extension FriendInviteStatusX on FriendInviteStatus {
  String get value {
    switch (this) {
      case FriendInviteStatus.pending:
        return 'pending';
      case FriendInviteStatus.accepted:
        return 'accepted';
      case FriendInviteStatus.rejected:
        return 'rejected';
      case FriendInviteStatus.expired:
        return 'expired';
    }
  }

  String get label {
    switch (this) {
      case FriendInviteStatus.pending:
        return 'Pending';
      case FriendInviteStatus.accepted:
        return 'Accepted';
      case FriendInviteStatus.rejected:
        return 'Rejected';
      case FriendInviteStatus.expired:
        return 'Expired';
    }
  }

  static FriendInviteStatus fromValue(String? value) {
    switch (value) {
      case 'accepted':
        return FriendInviteStatus.accepted;
      case 'rejected':
        return FriendInviteStatus.rejected;
      case 'expired':
        return FriendInviteStatus.expired;
      case 'pending':
      default:
        return FriendInviteStatus.pending;
    }
  }
}

class FriendShareEntity extends Equatable {
  const FriendShareEntity({
    required this.inviteId,
    required this.inviteCode,
    required this.inviteUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  final String inviteId;
  final String inviteCode;
  final String inviteUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [
    inviteId,
    inviteCode,
    inviteUrl,
    createdAt,
    expiresAt,
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
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.receiverUid,
    this.receiverName,
  });

  final String inviteId;
  final String inviteCode;
  final String senderUid;
  final String senderName;
  final String senderEmail;
  final String senderImage;
  final FriendInviteStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? receiverUid;
  final String? receiverName;

  bool get isPending => status == FriendInviteStatus.pending;

  @override
  List<Object?> get props => [
    inviteId,
    inviteCode,
    senderUid,
    senderName,
    senderEmail,
    senderImage,
    status,
    createdAt,
    expiresAt,
    receiverUid,
    receiverName,
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
