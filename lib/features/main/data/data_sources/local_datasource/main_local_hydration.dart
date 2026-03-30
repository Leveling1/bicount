import 'package:bicount/brick/repository.dart';
import 'package:brick_core/query.dart';
import 'package:brick_offline_first/brick_offline_first.dart'
    show OfflineFirstGetPolicy;
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:rxdart/rxdart.dart';

Future<void> primeUserSubject<T extends OfflineFirstWithSupabaseModel>(
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

Future<void> primeListSubject<T extends OfflineFirstWithSupabaseModel>(
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

Future<List<T>> loadInitialItems<T extends OfflineFirstWithSupabaseModel>(
  Query? query,
) async {
  try {
    return await Repository().get<T>(query: query);
  } catch (_) {
    return Repository().get<T>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: query,
    );
  }
}
