import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../models/transaction.model.dart';
import 'transaction_party_resolution_service.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(
    this.localDataSource, {
    this.splitResolver = const TransactionSplitResolver(),
    Future<void> Function(RecurringTransfertModel recurringTransfert)?
    saveRecurringTransfert,
  }) : _saveRecurringTransfert =
           saveRecurringTransfert ??
           OfflineFinanceLocalService().createRecurringTransfert;

  final TransactionLocalDataSource localDataSource;
  final TransactionSplitResolver splitResolver;
  final Future<void> Function(RecurringTransfertModel recurringTransfert)
  _saveRecurringTransfert;
  late final TransactionPartyResolutionService _partyResolutionService =
      TransactionPartyResolutionService(localDataSource);

  @override
  Future<void> createTransaction(
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      final partyTransactionType = _resolvePartyTransactionType(transaction);
      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _partyResolutionService.resolveParty(
        transaction.sender,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );
      final gtid = const Uuid().v4();
      final authenticatedUserId = _authenticatedUserIdOrNull();

      // Create a recurring template if the user enabled recurring mode.
      String? recurringTransfertId;
      int? generationMode;
      var shouldSaveLedgerRows = true;
      if (transaction.isRecurring &&
          transaction.recurringFrequency != null &&
          transaction.recurringTypeId != null) {
        final firstBeneficiary = await _partyResolutionService.resolveParty(
          resolvedSplits.first.beneficiary,
          transactionType: partyTransactionType,
          resolvedParties: resolvedParties,
        );
        final recurringOwnerId =
            authenticatedUserId ??
            (transaction.transactionType == 1
                ? firstBeneficiary.sid
                : sender.sid);
        final executionMode = _resolveRecurringExecutionMode(transaction);
        recurringTransfertId = const Uuid().v4();
        shouldSaveLedgerRows = _shouldSaveRecurringLedgerRows(transaction);
        generationMode = shouldSaveLedgerRows
            ? TransactionTypes.generationManualConfirmation
            : null;

        await _saveRecurringTransfert(
          RecurringTransfertModel(
            recurringTransfertId: recurringTransfertId,
            uid: recurringOwnerId,
            recurringTransfertTypeId: transaction.recurringTypeId!,
            title: transaction.name,
            note: transaction.note,
            amount: transaction.totalAmount,
            currency: transaction.currency,
            senderId: sender.sid,
            beneficiaryId: firstBeneficiary.sid,
            frequency: transaction.recurringFrequency!,
            startDate: transaction.date,
            nextDueDate: transaction.date,
            executionMode: executionMode,
            reminderEnabled: _resolveRecurringReminderEnabled(
              transaction,
              executionMode,
            ),
          ),
        );
      }

      if (!shouldSaveLedgerRows && recurringTransfertId != null) {
        return;
      }

      for (final split in resolvedSplits) {
        final beneficiary = await _partyResolutionService.resolveParty(
          split.beneficiary,
          transactionType: partyTransactionType,
          resolvedParties: resolvedParties,
        );
        final saveResult = await localDataSource.saveTransaction(
          gtid,
          title: transaction.name,
          type: partyTransactionType,
          date: transaction.date,
          amount: split.amount,
          category: transaction.category,
          currency: transaction.currency,
          note: transaction.note,
          senderId: sender.sid,
          beneficiaryId: beneficiary.sid,
          image: beneficiary.image.isEmpty
              ? Constants.memojiDefault
              : beneficiary.image,
          recurringTransfertId: recurringTransfertId,
          recurringOccurrenceDate: recurringTransfertId == null
              ? null
              : transaction.date,
          generationMode: generationMode,
        );

        await saveResult.fold(_throwFailure, (_) async => null);
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) async {
    try {
      final currentTransactions = await Repository().get<TransactionModel>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where.exact('tid', transaction.tid)]),
      );

      if (currentTransactions.isEmpty) {
        throw MessageFailure(
          message: 'Unable to delete this transaction right now.',
        );
      }

      await Repository().delete<TransactionModel>(currentTransactions.first);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to delete this transaction right now.',
      );
    }
  }

  @override
  Future<void> updateTransaction(
    TransactionEntity previousTransaction,
    CreateTransactionRequestEntity transaction,
  ) async {
    try {
      final resolvedSplits = splitResolver.resolve(transaction);
      final partyTransactionType = _resolvePartyTransactionType(transaction);
      if (resolvedSplits.length != 1) {
        throw MessageFailure(
          message: 'Edit this transaction with one beneficiary only.',
        );
      }

      final resolvedParties = <String, _ResolvedParty>{};
      final sender = await _partyResolutionService.resolveParty(
        transaction.sender,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );
      final split = resolvedSplits.single;
      final beneficiary = await _partyResolutionService.resolveParty(
        split.beneficiary,
        transactionType: partyTransactionType,
        resolvedParties: resolvedParties,
      );
      final result = await localDataSource.updateTransaction(
        previousTransaction,
        title: transaction.name,
        type: partyTransactionType,
        date: transaction.date,
        amount: split.amount,
        category: transaction.category,
        currency: transaction.currency,
        note: transaction.note,
        senderId: sender.sid,
        beneficiaryId: beneficiary.sid,
        image: beneficiary.image.isEmpty
            ? Constants.memojiDefault
            : beneficiary.image,
      );

      await result.fold(_throwFailure, (_) async => null);
    } on Failure {
      rethrow;
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }

  String? _authenticatedUserIdOrNull() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  int _resolvePartyTransactionType(CreateTransactionRequestEntity transaction) {
    return transaction.recurringTypeId ?? transaction.transactionType;
  }

  bool _shouldSaveRecurringLedgerRows(
    CreateTransactionRequestEntity transaction,
  ) {
    return !_isRecurringSalary(transaction);
  }

  int _resolveRecurringExecutionMode(
    CreateTransactionRequestEntity transaction,
  ) {
    if (_isRecurringSalary(transaction)) {
      return AppExecutionMode.normalize(transaction.recurringExecutionMode);
    }

    return AppExecutionMode.manualConfirmation;
  }

  bool _resolveRecurringReminderEnabled(
    CreateTransactionRequestEntity transaction,
    int executionMode,
  ) {
    if (_isRecurringSalary(transaction) &&
        AppExecutionMode.isAutomatic(executionMode)) {
      return false;
    }

    return transaction.recurringReminderEnabled ?? true;
  }

  bool _isRecurringSalary(CreateTransactionRequestEntity transaction) {
    return transaction.isRecurring &&
        transaction.recurringTypeId == TransactionTypes.salaryCode;
  }
}

typedef _ResolvedParty = ResolvedTransactionParty;
