part of 'friend_bloc.dart';

enum FriendStatus { initial, loading, ready, failure }

const _friendStateUnset = Object();

class FriendState {
  const FriendState({
    required this.status,
    required this.hub,
    this.invitePreview,
    this.errorMessage,
    this.flashMessage,
    required this.isSubmitting,
  });

  final FriendStatus status;
  final FriendHubEntity hub;
  final FriendInviteEntity? invitePreview;
  final String? errorMessage;
  final String? flashMessage;
  final bool isSubmitting;

  factory FriendState.initial() {
    return const FriendState(
      status: FriendStatus.initial,
      hub: FriendHubEntity(sentInvites: [], receivedInvites: []),
      isSubmitting: false,
    );
  }

  FriendState copyWith({
    FriendStatus? status,
    FriendHubEntity? hub,
    Object? invitePreview = _friendStateUnset,
    Object? errorMessage = _friendStateUnset,
    Object? flashMessage = _friendStateUnset,
    bool? isSubmitting,
  }) {
    return FriendState(
      status: status ?? this.status,
      hub: hub ?? this.hub,
      invitePreview: invitePreview == _friendStateUnset
          ? this.invitePreview
          : invitePreview as FriendInviteEntity?,
      errorMessage: errorMessage == _friendStateUnset
          ? this.errorMessage
          : errorMessage as String?,
      flashMessage: flashMessage == _friendStateUnset
          ? this.flashMessage
          : flashMessage as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
