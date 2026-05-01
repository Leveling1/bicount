import 'dart:async';

import 'package:bicount/features/notification/data/data_sources/local_datasource/notification_local_datasource.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/notification_remote_datasource.dart';
import 'package:bicount/features/notification/domain/entities/app_notification_entity.dart';
import 'package:bicount/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteDataSource;

  final StreamController<AppNotificationEntity> _controller =
      StreamController<AppNotificationEntity>.broadcast();
  StreamSubscription<AppNotificationEntity>? _foregroundSubscription;
  StreamSubscription<AppNotificationEntity>? _openedSubscription;
  StreamSubscription<AppNotificationEntity>? _deepLinkSubscription;

  @override
  Future<void> initialize() async {
    await localDataSource.initialize(_controller.add);
    _registerEventStreams();

    final initialEvent = await remoteDataSource.getInitialEvent();
    if (initialEvent != null) {
      _controller.add(initialEvent);
    }
  }

  void _registerEventStreams() {
    _foregroundSubscription ??= remoteDataSource.foregroundMessages().listen((
      notification,
    ) async {
      _controller.add(notification);
      await localDataSource.showForegroundNotification(notification);
    });

    _openedSubscription ??= remoteDataSource.openedMessages().listen(
      _controller.add,
    );
    _deepLinkSubscription ??= remoteDataSource.deepLinks().listen(
      _controller.add,
    );
  }

  @override
  Future<void> enableAuthenticatedNotifications() async {
    await localDataSource.requestPermission();
    await remoteDataSource.requestPermission();
    await remoteDataSource.syncDeviceToken();
  }

  @override
  Stream<AppNotificationEntity> watchEvents() => _controller.stream;
}
