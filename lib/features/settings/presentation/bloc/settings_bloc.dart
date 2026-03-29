import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._repository) : super(const SettingsState()) {
    on<SettingsProfileUpdatedRequested>(_onProfileUpdatedRequested);
    on<SettingsProAccessRequested>(_onProAccessRequested);
    on<SettingsSignOutRequested>(_onSignOutRequested);
    on<SettingsDeleteAccountRequested>(_onDeleteAccountRequested);
    on<SettingsFeedbackConsumed>(_onFeedbackConsumed);
  }

  final SettingsRepositoryImpl _repository;

  Future<void> _onProfileUpdatedRequested(
    SettingsProfileUpdatedRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _runAction(
      emit,
      action: SettingsPendingAction.profile,
      successMessage: 'Profile updated successfully.',
      task: () => _repository.updateProfile(event.update),
    );
  }

  Future<void> _onProAccessRequested(
    SettingsProAccessRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _runAction(
      emit,
      action: SettingsPendingAction.pro,
      successMessage: 'Your Bicount Pro request has been sent.',
      task: () => _repository.requestProAccess(event.request),
    );
  }

  Future<void> _onSignOutRequested(
    SettingsSignOutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _runAction(
      emit,
      action: SettingsPendingAction.signOut,
      successMessage: 'You have been signed out.',
      task: _repository.signOut,
    );
  }

  Future<void> _onDeleteAccountRequested(
    SettingsDeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _runAction(
      emit,
      action: SettingsPendingAction.deleteAccount,
      successMessage: 'Your account deletion request has been submitted.',
      task: () => _repository.deleteAccount(event.request),
    );
  }

  void _onFeedbackConsumed(
    SettingsFeedbackConsumed event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }

  Future<void> _runAction(
    Emitter<SettingsState> emit, {
    required SettingsPendingAction action,
    required String successMessage,
    required Future<void> Function() task,
  }) async {
    emit(state.copyWith(pendingAction: action, clearFeedback: true));

    try {
      await task();
      emit(
        state.copyWith(
          clearPendingAction: true,
          feedback: SettingsFeedback(
            action: action,
            message: successMessage,
            isError: false,
          ),
        ),
      );
    } on Failure catch (error) {
      emit(
        state.copyWith(
          clearPendingAction: true,
          feedback: SettingsFeedback(
            action: action,
            message: error.message,
            isError: true,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          clearPendingAction: true,
          feedback: SettingsFeedback(
            action: action,
            message: 'An unexpected error occurred.',
            isError: true,
          ),
        ),
      );
    }
  }
}
