import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debt booleans and numeric amounts survive local storage', () {
    final codec = codecFor<DebtModel>();
    final remote = <String, dynamic>{
      'debt_id': 'debt-1',
      'created_by': 'user-1',
      'lender_id': 'user-1',
      'borrower_id': 'friend-1',
      'principal_transaction_id': 'transaction-1',
      'title': 'Loan',
      'note': '',
      'currency': 'USD',
      'principal_amount': 100,
      'expected_repayment_amount': 100,
      'repaid_amount': 25,
      'remaining_amount': 75,
      'due_date': '2026-12-01',
      'status': 1,
      'reminder_enabled': true,
    };
    final local = codec.toLocal(codec.fromRemote(remote));
    final restored = codec.fromLocal(local);

    expect(restored.debtId, 'debt-1');
    expect(restored.principalAmount, 100.0);
    expect(restored.remainingAmount, 75.0);
    expect(restored.reminderEnabled, isTrue);
    expect(local['reminder_enabled'], 1);
  });

  test('friend local calculations are not sent to Supabase', () {
    final codec = codecFor<FriendsModel>();
    final friend = FriendsModel(
      sid: 'friend-1',
      uid: null,
      fid: 'user-1',
      image: '',
      username: 'Alex',
      email: 'a@example.com',
      relationType: 0,
      give: 20,
      receive: 5,
    );

    expect(codec.toLocal(friend)['give'], 20);
    expect(codec.toRemote(friend).containsKey('give'), isFalse);
    expect(codec.fromLocal(codec.toLocal(friend)).receive, 5);
  });

  test('backend recurring linkage survives a local transaction round trip', () {
    final codec = codecFor<TransactionModel>();
    final transaction = codec.fromRemote({
      'tid': 'transaction-1',
      'gtid': 'group-1',
      'uid': 'user-1',
      'name': 'Salary',
      'type': 3,
      'sender_id': 'user-1',
      'beneficiary_id': 'user-1',
      'date': '2026-04-09',
      'amount': 100,
      'currency': 'USD',
      'recurring_transfert_id': 'plan-1',
      'recurring_occurrence_date': '2026-04-09',
    });
    final restored = codec.fromLocal(codec.toLocal(transaction));

    expect(restored.recurringTransfertId, 'plan-1');
    expect(restored.recurringOccurrenceDate, '2026-04-09');
    expect(codec.toRemote(restored)['recurring_transfert_id'], 'plan-1');
  });
}
