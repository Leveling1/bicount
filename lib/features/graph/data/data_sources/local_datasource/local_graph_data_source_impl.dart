import 'dart:async';

import 'package:bicount/brick/repository.dart';
import 'package:bicount/features/graph/data/data_sources/local_datasource/graph_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalGraphDataSourceImpl implements GraphLocalDataSource {
  LocalGraphDataSourceImpl() {
    _activeUserId = _supabase.auth.currentUser?.id;
    _authSubscription = _supabase.auth.onAuthStateChange.listen((state) {
      final nextUserId = state.session?.user.id;
      if (nextUserId != _activeUserId) {
        _activeUserId = nextUserId;
        _resetCaches();
      }
    });
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  String? _activeUserId;
  StreamSubscription<dynamic>? _authSubscription;

  BehaviorSubject<List<TransactionModel>>? _transactionsSubject;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return _cachedListStream<TransactionModel>(
      getSubject: () => _transactionsSubject,
      setSubject: (subject) => _transactionsSubject = subject,
      getSubscription: () => _transactionsSubscription,
      setSubscription: (subscription) =>
          _transactionsSubscription = subscription,
    );
  }

  Stream<List<T>> _cachedListStream<T extends OfflineFirstWithSupabaseModel>({
    required BehaviorSubject<List<T>>? Function() getSubject,
    required void Function(BehaviorSubject<List<T>> subject) setSubject,
    required StreamSubscription<List<T>>? Function() getSubscription,
    required void Function(StreamSubscription<List<T>> subscription)
    setSubscription,
  }) {
    final existing = getSubject();
    if (existing != null) {
      return existing.stream;
    }

    final subject = BehaviorSubject<List<T>>();
    setSubject(subject);

    final subscription = Repository().subscribeToRealtime<T>().listen(
      subject.add,
      onError: subject.addError,
    );
    setSubscription(subscription);
    return subject.stream;
  }

  void _resetCaches() {
    _transactionsSubscription?.cancel();
    _transactionsSubject?.close();
    _transactionsSubscription = null;
    _transactionsSubject = null;
  }

  void dispose() {
    _authSubscription?.cancel();
    _resetCaches();
  }
}
