import 'package:bicount/features/notification/domain/entities/notifiable_action.dart';

abstract class NotificationPermissionLocalDataSource {
  Future<bool> isActionGranted(NotifiableAction action);
  Future<Set<NotifiableAction>> getGrantedActions();
  Future<void> markActionGranted(NotifiableAction action);
  Future<String?> getLastFcmToken();
  Future<void> saveFcmToken(String token);
}
