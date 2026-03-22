import 'package:equatable/equatable.dart';

enum SettingsPendingAction { profile, pro, signOut, deleteAccount }

class SettingsFeedback extends Equatable {
  const SettingsFeedback({
    required this.action,
    required this.message,
    required this.isError,
  });

  final SettingsPendingAction action;
  final String message;
  final bool isError;

  @override
  List<Object?> get props => [action, message, isError];
}

class SettingsState extends Equatable {
  const SettingsState({this.pendingAction, this.feedback});

  final SettingsPendingAction? pendingAction;
  final SettingsFeedback? feedback;

  bool isPending(SettingsPendingAction action) => pendingAction == action;

  SettingsState copyWith({
    SettingsPendingAction? pendingAction,
    bool clearPendingAction = false,
    SettingsFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return SettingsState(
      pendingAction: clearPendingAction
          ? null
          : pendingAction ?? this.pendingAction,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [pendingAction, feedback];
}
