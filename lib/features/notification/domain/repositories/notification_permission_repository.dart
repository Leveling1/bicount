import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';

abstract class NotificationPermissionRepository {
  Future<bool> isActionGranted(NotifiableAction action);
  Future<Set<NotifiableAction>> getGrantedActions();
  Future<void> markActionGranted(NotifiableAction action);
  Future<bool> requestOsPermission();
  Future<bool> isOsPermissionAuthorized();
  Future<void> syncDeviceToken();
  Future<bool> hasFcmTokenChanged();
}
