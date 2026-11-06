import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
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
}
