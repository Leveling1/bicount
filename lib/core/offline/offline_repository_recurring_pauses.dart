part of 'repository.dart';

extension OfflineRecurringPauses on Repository {
  Future<void> saveRecurringConfirmation(
    TransactionModel transaction, {
    required String planId,
    required DateTime expectedDate,
  }) => _upsert(
    transaction,
    isCreation: true,
    validate: (tx, uid) async {
      if (uid != currentUserId || transaction.uid != uid) {
        throw StateError('The recurring plan account changed.');
      }
      final plan = await _loadRecurringPlan(tx, planId);
      if (plan == null ||
          plan.uid != uid ||
          !canConfirmRecurringDate(plan, expectedDate)) {
        throw StateError('Recurring occurrence is unavailable.');
      }
    },
  );

  Stream<List<RecurringTransfertModel>> watchRecurringPlans() =>
      Rx.combineLatest2(
        subscribeToRealtime<RecurringTransfertModel>(),
        subscribeToRealtime<RecurringPlanPause>(),
        _attachRecurringPauses,
      );

  Future<List<RecurringTransfertModel>> readRecurringPlans({
    Query? query,
  }) async {
    final uid = currentUserId;
    final (plans, pauses) = await (
      localGet<RecurringTransfertModel>(query: query),
      localGet<RecurringPlanPause>(),
    ).wait;
    return currentUserId == uid ? _attachRecurringPauses(plans, pauses) : [];
  }

  Future<void> changeRecurringPauses({
    required String ownerUid,
    required RecurringPlanPauseAction action,
    required List<RecurringPlanPauseChange> changes,
  }) async {
    if (changes.isEmpty) return;
    final (uid, db) = await _writableDatabase();
    final pauseCodec = recurringPlanPauseCodec;
    final outbox = OfflineOutbox(db);
    await db.transaction((tx) async {
      if (currentUserId != uid || ownerUid != uid) {
        throw StateError('The recurring plan account changed.');
      }
      final now = DateTime.now();
      final dayFormat = DateFormat('yyyy-MM-dd', 'en');
      final today = dayFormat.format(now);
      final seen = <String>{};
      final operations = <OfflineOperation>[];
      for (final change in changes) {
        if (!seen.add(change.planId)) throw StateError('Duplicate plan.');
        final plan = await _loadRecurringPlan(tx, change.planId);
        if (plan == null || plan.uid != uid || !plan.hasSchedule) {
          throw StateError('Recurring plan is unavailable.');
        }
        final open = plan.pauses.where((pause) => pause.isOpen).singleOrNull;
        final resuming = action == RecurringPlanPauseAction.resume;
        if (resuming != (open != null)) {
          throw StateError('The recurring plan status changed.');
        }
        final end = const RecurringPlanSchedule().scheduleService.parseDate(
          plan.endDate,
        );
        final override = change.nextDueDate;
        final overrideDay = override == null
            ? null
            : dayFormat.format(override);
        if (overrideDay != null &&
            (!resuming ||
                overrideDay.compareTo(today) < 0 ||
                (end != null &&
                    overrideDay.compareTo(dayFormat.format(end)) > 0))) {
          throw StateError('Invalid recurring due date.');
        }
        final pause = RecurringPlanPause(
          id: open?.id ?? const Uuid().v4(),
          planId: change.planId,
          pausedAt: open?.pausedAt ?? now,
          pausedOn: open?.pausedOn ?? today,
          resumedAt: resuming ? now : null,
          resumedOn: resuming ? today : null,
          nextDueDateOverride: overrideDay,
        );
        operations.add(
          OfflineOperation(
            userId: uid,
            collection: pauseCodec.table,
            recordId: pause.id,
            action: 'upsert',
            payload: pause.toRow(),
          ),
        );
      }
      if (currentUserId != uid) throw StateError('The account changed.');
      await outbox.commitBatchInTransaction(
        tx,
        operations,
        (tx, operation) => tx.insert(
          pauseCodec.localTable,
          operation.payload,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      );
    });
    notifyType(RecurringPlanPause);
    _sync.schedule();
  }
}

Future<RecurringTransfertModel?> _loadRecurringPlan(
  Transaction tx,
  String id,
) async {
  final planCodec = recurringTransfertModelCodec;
  final planRows = await tx.query(
    planCodec.localTable,
    where: '"${planCodec.localKey}" = ?',
    whereArgs: [id],
  );
  if (planRows.isEmpty) return null;
  final pauseCodec = recurringPlanPauseCodec;
  final pauseRows = await tx.query(
    pauseCodec.localTable,
    where: 'recurring_transfert_id = ?',
    whereArgs: [id],
  );
  return _attachRecurringPauses(
    planRows.map(planCodec.fromLocal).toList(),
    pauseRows.map(pauseCodec.fromLocal).toList(),
  ).single;
}

List<RecurringTransfertModel> _attachRecurringPauses(
  List<RecurringTransfertModel> plans,
  List<RecurringPlanPause> pauses,
) {
  final byPlan = <String, List<RecurringPlanPause>>{};
  for (final pause in pauses) {
    byPlan.putIfAbsent(pause.planId, () => []).add(pause);
  }
  for (final history in byPlan.values) {
    history.sort((a, b) => a.pausedAt.compareTo(b.pausedAt));
  }
  return plans.map((plan) {
    final history = byPlan[plan.recurringTransfertId];
    return history == null ? plan : plan.withPauses(history);
  }).toList();
}
