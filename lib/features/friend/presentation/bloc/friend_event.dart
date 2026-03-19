part of 'friend_bloc.dart';

sealed class FriendEvent {
  const FriendEvent();
}

final class FriendStarted extends FriendEvent {
  const FriendStarted();
}

final class FriendCreateInviteRequested extends FriendEvent {
  const FriendCreateInviteRequested({
    required this.senderName,
    required this.senderEmail,
    required this.senderImage,
    required this.sourceFriendSid,
    required this.sourceFriendName,
    required this.sourceFriendEmail,
    required this.sourceFriendImage,
  });

  final String senderName;
  final String senderEmail;
  final String senderImage;
  final String sourceFriendSid;
  final String sourceFriendName;
  final String sourceFriendEmail;
  final String sourceFriendImage;
}

final class FriendInviteCodeReceived extends FriendEvent {
  const FriendInviteCodeReceived(this.rawValue);

  final String rawValue;
}

final class FriendAcceptRequested extends FriendEvent {
  const FriendAcceptRequested();
}

final class FriendRejectRequested extends FriendEvent {
  const FriendRejectRequested();
}

final class FriendPreviewCleared extends FriendEvent {
  const FriendPreviewCleared();
}

final class _FriendHubUpdated extends FriendEvent {
  const _FriendHubUpdated(this.hub);

  final FriendHubEntity hub;
}

final class _FriendActionSucceeded extends FriendEvent {
  const _FriendActionSucceeded(this.message);

  final String message;
}

final class _FriendActionFailed extends FriendEvent {
  const _FriendActionFailed(this.message);

  final String message;
}
