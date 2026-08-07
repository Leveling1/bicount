import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';

abstract class NotificationPermissionRepository {
  Future<bool> isActionGranted(NotifiableAction action);
  Future<Set<NotifiableAction>> getGrantedActions();
  Future<void> markActionGranted(NotifiableAction action);
  Future<bool> requestOsPermission();
  Future<bool> isOsPermissionAuthorized();

  /// True only when the OS has already recorded an explicit user denial
  /// (e.g. iOS's `AuthorizationStatus.denied`). On iOS the native permission
  /// dialog can only ever be shown once per app install — every later call
  /// to [requestOsPermission] silently resolves to denied without any UI.
  /// Callers should use this to stop offering to re-request permission
  /// instead of repeatedly showing a prompt that can no longer do anything.
  Future<bool> isOsPermissionPermanentlyDenied();
  Future<void> syncDeviceToken();
  Future<bool> hasFcmTokenChanged();
}
