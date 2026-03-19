import 'dart:async';

import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/domain/repositories/friend_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc(this.repository) : super(FriendState.initial()) {
    on<FriendStarted>(_onFriendStarted);
    on<FriendCreateInviteRequested>(_onFriendCreateInviteRequested);
    on<FriendInviteCodeReceived>(_onFriendInviteCodeReceived);
    on<FriendAcceptRequested>(_onFriendAcceptRequested);
    on<FriendRejectRequested>(_onFriendRejectRequested);
    on<FriendPreviewCleared>(_onFriendPreviewCleared);
    on<_FriendHubUpdated>(_onFriendHubUpdated);
    on<_FriendActionSucceeded>(_onFriendActionSucceeded);
    on<_FriendActionFailed>(_onFriendActionFailed);
  }

  final FriendRepository repository;
  StreamSubscription<FriendHubEntity>? _hubSubscription;

  Future<void> _onFriendStarted(
    FriendStarted event,
    Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    await _hubSubscription?.cancel();
    _hubSubscription = repository.watchHub().listen(
      (hub) => add(_FriendHubUpdated(hub)),
      onError: (error, _) => add(_FriendActionFailed(error.toString())),
    );
  }

  Future<void> _onFriendCreateInviteRequested(
    FriendCreateInviteRequested event,
    Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, flashMessage: null));
    try {
      await repository.createInvite(
        senderName: event.senderName,
        senderEmail: event.senderEmail,
        senderImage: event.senderImage,
        sourceFriendSid: event.sourceFriendSid,
        sourceFriendName: event.sourceFriendName,
        sourceFriendEmail: event.sourceFriendEmail,
        sourceFriendImage: event.sourceFriendImage,
      );
      add(const _FriendActionSucceeded('Invitation ready to share.'));
    } catch (error) {
      add(_FriendActionFailed(error.toString()));
    }
  }

  Future<void> _onFriendInviteCodeReceived(
    FriendInviteCodeReceived event,
    Emitter<FriendState> emit,
  ) async {
    final inviteCode = repository.extractInviteCode(event.rawValue);
    if (inviteCode == null) {
      emit(
        state.copyWith(
          errorMessage: 'Unable to read this invitation.',
          flashMessage: null,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final invite = await repository.getInviteByCode(inviteCode);
      if (invite == null) {
        add(const _FriendActionFailed('This invitation was not found.'));
        return;
      }

      emit(
        state.copyWith(
          invitePreview: invite,
          isSubmitting: false,
          flashMessage: null,
        ),
      );
    } catch (error) {
      add(_FriendActionFailed(error.toString()));
    }
  }

  Future<void> _onFriendAcceptRequested(
    FriendAcceptRequested event,
    Emitter<FriendState> emit,
  ) async {
    final invite = state.invitePreview;
    if (invite == null) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, flashMessage: null));
    try {
      await repository.acceptInvite(invite.inviteCode);
      add(const _FriendActionSucceeded('Invitation accepted.'));
      emit(state.copyWith(invitePreview: null));
    } catch (error) {
      add(_FriendActionFailed(error.toString()));
    }
  }

  Future<void> _onFriendRejectRequested(
    FriendRejectRequested event,
    Emitter<FriendState> emit,
  ) async {
    final invite = state.invitePreview;
    if (invite == null) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, flashMessage: null));
    try {
      await repository.rejectInvite(invite.inviteCode);
      add(const _FriendActionSucceeded('Invitation rejected.'));
      emit(state.copyWith(invitePreview: null));
    } catch (error) {
      add(_FriendActionFailed(error.toString()));
    }
  }

  void _onFriendPreviewCleared(
    FriendPreviewCleared event,
    Emitter<FriendState> emit,
  ) {
    emit(state.copyWith(invitePreview: null, flashMessage: null));
  }

  void _onFriendHubUpdated(_FriendHubUpdated event, Emitter<FriendState> emit) {
    emit(
      state.copyWith(
        status: FriendStatus.ready,
        hub: event.hub,
        isSubmitting: false,
        errorMessage: null,
      ),
    );
  }

  void _onFriendActionSucceeded(
    _FriendActionSucceeded event,
    Emitter<FriendState> emit,
  ) {
    emit(
      state.copyWith(
        isSubmitting: false,
        errorMessage: null,
        flashMessage: event.message,
      ),
    );
  }

  void _onFriendActionFailed(
    _FriendActionFailed event,
    Emitter<FriendState> emit,
  ) {
    emit(
      state.copyWith(
        status: FriendStatus.failure,
        isSubmitting: false,
        errorMessage: event.message,
        flashMessage: null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _hubSubscription?.cancel();
    return super.close();
  }
}
