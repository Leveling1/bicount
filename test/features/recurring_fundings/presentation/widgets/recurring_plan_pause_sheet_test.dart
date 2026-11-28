import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_pause_action.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_pause_sheet.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk resume sends each selected plan with its own date', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      RepositoryProvider<RecurringTransfertRepositoryImpl>.value(
        value: repository,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showRecurringPlanPauseSheet(
                  context,
                  action: RecurringPlanPauseAction.resume,
                  plans: [_plan('Rent'), _plan('Salary'), _plan('Other')],
                  bulk: true,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a new first due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();

    final submit = find.widgetWithText(ElevatedButton, 'Resume plans');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(repository.action, RecurringPlanPauseAction.resume);
    expect(repository.changes.map((change) => change.planId), [
      'Rent',
      'Salary',
    ]);
    expect(
      repository.changes.first.nextDueDate,
      DateUtils.dateOnly(DateTime.now()),
    );
    expect(repository.changes.last.nextDueDate, isNull);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}

class _Repository extends Fake implements RecurringTransfertRepositoryImpl {
  RecurringPlanPauseAction? action;
  List<RecurringPlanPauseChange> changes = [];

  @override
  Future<void> changePauses({
    required String ownerUid,
    required RecurringPlanPauseAction action,
    required List<RecurringPlanPauseChange> changes,
  }) async {
    expect(ownerUid, 'owner');
    this.action = action;
    this.changes = changes;
  }
}

RecurringPlanSummaryEntity _plan(String name) => RecurringPlanSummaryEntity(
  recurringTransfert: RecurringTransfertModel(
    recurringTransfertId: name,
    uid: 'owner',
    recurringTransfertTypeId: 3,
    title: name,
    amount: 50,
    currency: 'USD',
    senderId: 'owner',
    beneficiaryId: 'contact',
    frequency: Frequency.monthly,
    startDate: '2026-11-01',
    nextDueDate: '2026-11-01',
  ),
  nextExpectedDate: null,
  lastRecordedDate: null,
  monthlyReferenceAmount: 50,
  totalRecordedReferenceAmount: 0,
  recordedCount: 0,
);
