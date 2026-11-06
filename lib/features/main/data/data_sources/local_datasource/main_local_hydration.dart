import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:rxdart/rxdart.dart';

Future<void> primeUserSubject<T extends OfflineModel>(
  BehaviorSubject<T> subject,
  Query query,
) async {
  try {
    final items = await loadInitialItems<T>(query);
    if (!subject.isClosed && items.isNotEmpty) {
      subject.add(items.first);
    }
  } catch (error) {
    if (!subject.isClosed) {
      subject.addError(error);
    }
  }
}

Future<void> primeListSubject<T extends OfflineModel>(
  BehaviorSubject<List<T>> subject,
  Query? query,
) async {
  try {
    final items = await loadInitialItems<T>(query);
    if (!subject.isClosed) {
      subject.add(items);
    }
  } catch (error) {
    if (!subject.isClosed) {
      subject.addError(error);
    }
  }
}

Future<List<T>> loadInitialItems<T extends OfflineModel>(Query? query) async {
  final localItems = await Repository().get<T>(
    policy: OfflineReadPolicy.localOnly,
    query: query,
  );
  if (localItems.isNotEmpty) {
    return localItems;
  }
  try {
    return await Repository().get<T>(query: query);
  } catch (_) {
    return localItems;
  }
}
