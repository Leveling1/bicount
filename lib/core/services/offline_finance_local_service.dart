import 'dart:async';

import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart';

import 'offline_finance_delta_calculator.dart';

class OfflineFinanceLocalService {
  OfflineFinanceLocalService({
    OfflineFinanceDeltaCalculator calculator =
        const OfflineFinanceDeltaCalculator(),
  }) : _calculator = calculator;

  final OfflineFinanceDeltaCalculator _calculator;

  Future<void> applyTransactionEffects({
    required String currentUserId,
    required TransactionModel transaction,
  }) async {
    final category = transaction.category ?? Constants.personal;
    await _applyTransactionSide(
      currentUserId: currentUserId,
      partyId: transaction.senderId,
      amount: transaction.amount,
      category: category,
      isSender: true,
    );
    await _applyTransactionSide(
      currentUserId: currentUserId,
      partyId: transaction.beneficiaryId,
      amount: transaction.amount,
      category: category,
      isSender: false,
    );
  }

  Future<void> createRecurringTransfert(
    RecurringTransfertModel recurringTransfert,
  ) async {
    await Repository().sqliteProvider.upsert<RecurringTransfertModel>(
      recurringTransfert,
      repository: Repository(),
    );
    unawaited(
      Repository()
          .upsert<RecurringTransfertModel>(recurringTransfert)
          // ignore: body_might_complete_normally_catch_error
          .catchError((e) {
            debugPrint('Background recurring transfert sync: $e');
          }),
    );
  }

  Future<void> _applyTransactionSide({
    required String currentUserId,
    required String partyId,
    required double amount,
    required int category,
    required bool isSender,
  }) async {
    if (partyId == currentUserId) {
      final user = await _findUser(currentUserId);
      if (user == null) return;
      final updatedUser = _calculator.applyTransactionToUser(
        user: user,
        isSender: isSender,
        amount: amount,
        category: category,
      );
      await Repository().sqliteProvider.upsert<UserModel>(
        updatedUser,
        repository: Repository(),
      );
      unawaited(
        // ignore: body_might_complete_normally_catch_error
        Repository().upsert<UserModel>(updatedUser).catchError((e) {
          debugPrint('Background user sync: $e');
        }),
      );
      return;
    }
  }

  Future<UserModel?> _findUser(String uid) => _firstOrNull(
    Repository().get<UserModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('uid', uid)]),
    ),
  );

  // ignore: unused_element
  Future<CompanyModel?> _findCompany(String cid) => _firstOrNull(
    Repository().get<CompanyModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('cid', cid)]),
    ),
  );

  Future<T?> _firstOrNull<T>(Future<List<T>> future) async {
    final items = await future;
    return items.isEmpty ? null : items.first;
  }
}
