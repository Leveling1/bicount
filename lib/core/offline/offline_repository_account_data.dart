part of 'repository.dart';

extension OfflineRepositoryAccountData on Repository {
  Future<void> purgeDeletedAccountData(String uid) async {
    if (currentUserId == uid) {
      throw StateError('Sign out before removing deleted account data.');
    }
    await _sync.pause();
    final open = _databases.remove(uid);
    if (open != null) await (await open).close();
    final directory = await Repository._factory.getDatabasesPath();
    final target = path.join(
      directory,
      '${BackendEnvironment.isLocalPreproduction ? 'bicount_preprod_' : 'bicount_'}'
      '${uid.replaceAll('-', '')}.sqlite',
    );
    if (!path.isWithin(directory, target)) {
      throw StateError('Local database path escaped the app directory.');
    }
    for (final suffix in const ['', '-wal', '-shm', '-journal']) {
      final file = File('$target$suffix');
      if (await file.exists()) await file.delete();
    }
    final legacy = path.join(directory, 'my_repository.sqlite');
    if (!BackendEnvironment.isLocalPreproduction &&
        await legacyDatabaseBelongsTo(Repository._factory, legacy, uid)) {
      for (final name in const [
        'my_repository.sqlite',
        'brick_offline_queue.sqlite',
      ]) {
        final source = path.join(directory, name);
        for (final suffix in const ['', '-wal', '-shm', '-journal']) {
          final file = File('$source$suffix');
          if (await file.exists()) await file.delete();
        }
      }
    }
  }
}
