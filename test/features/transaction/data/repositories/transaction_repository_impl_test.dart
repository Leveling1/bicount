import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transaction_repository_impl_test_support.dart';

void main() {
  test(
    'recurring transaction creates one placeholder friend and reuses it for the template and ledger row',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringExpenseRequest(
          draftParty(username: 'Netflix', relationType: FriendConst.friend),
        ),
      );

      expect(localDataSource.createFriendCallCount, 1);
      expect(localDataSource.savedTransactions, hasLength(1));
      expect(savedRecurringTransfert, isNotNull);
      expect(
        savedRecurringTransfert?.beneficiaryId,
        localDataSource.createdFriends.single.sid,
      );
      expect(
        localDataSource.savedTransactions.single.beneficiaryId,
        localDataSource.createdFriends.single.sid,
      );
      expect(
        localDataSource.createdFriends.single.relationType,
        FriendConst.subscription,
      );
      expect(localDataSource.savedTransactions.single.generationMode, 1);
    },
  );

  test(
    'recurring salary with manual confirmation only saves the template and keeps reminders enabled',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringSalaryRequest(
          draftParty(username: 'Employer', relationType: FriendConst.friend),
          executionMode: AppExecutionMode.manualConfirmation,
          reminderEnabled: true,
        ),
      );

      expect(localDataSource.createFriendCallCount, 1);
      expect(localDataSource.savedTransactions, isEmpty);
      expect(savedRecurringTransfert, isNotNull);
      expect(
        savedRecurringTransfert?.senderId,
        localDataSource.createdFriends.single.sid,
      );
      expect(savedRecurringTransfert?.beneficiaryId, currentUser().sid);
      expect(
        localDataSource.createdFriends.single.relationType,
        FriendConst.company,
      );
      expect(
        savedRecurringTransfert?.executionMode,
        AppExecutionMode.manualConfirmation,
      );
      expect(savedRecurringTransfert?.reminderEnabled, isTrue);
    },
  );

  test(
    'recurring salary with automatic mode saves only the template and disables reminders',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringSalaryRequest(
          draftParty(username: 'Employer', relationType: FriendConst.friend),
          executionMode: AppExecutionMode.backendAutomatic,
          reminderEnabled: true,
        ),
      );

      expect(localDataSource.savedTransactions, isEmpty);
      expect(savedRecurringTransfert, isNotNull);
      expect(
        savedRecurringTransfert?.executionMode,
        AppExecutionMode.backendAutomatic,
      );
      expect(savedRecurringTransfert?.reminderEnabled, isFalse);
    },
  );

  test(
    'recurring transaction reuses an existing matching placeholder friend instead of creating a duplicate',
    () async {
      final existingFriend = FriendsModel(
        sid: 'existing-subscription',
        uid: null,
        fid: 'owner-1',
        username: 'Netflix',
        image: '',
        email: '',
        relationType: FriendConst.subscription,
      );
      final localDataSource = FakeTransactionLocalDataSource(
        matchingFriend: existingFriend,
      );
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringExpenseRequest(
          draftParty(username: 'Netflix', relationType: FriendConst.friend),
        ),
      );

      expect(localDataSource.findMatchingFriendCallCount, 1);
      expect(localDataSource.createFriendCallCount, 0);
      expect(savedRecurringTransfert?.beneficiaryId, existingFriend.sid);
      expect(
        localDataSource.savedTransactions.single.beneficiaryId,
        existingFriend.sid,
      );
    },
  );

  test(
    'editing a revenue into a debt creates the debt contract and links the transaction',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      DebtModel? savedDebt;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveDebt: (debt) async {
          savedDebt = debt;
        },
      );
      final previousTransaction = convertibleIncomeTransaction();

      await repository.updateTransaction(
        previousTransaction,
        incomeDebtUpdateRequest(),
      );

      expect(savedDebt, isNotNull);
      expect(savedDebt?.principalTransactionId, previousTransaction.tid);
      expect(savedDebt?.lenderId, 'created-1');
      expect(savedDebt?.borrowerId, currentUser().sid);
      expect(localDataSource.updatedTransaction, isNotNull);
      expect(localDataSource.updatedTransaction?.type, TransactionTypes.debtCode);
      expect(localDataSource.updatedTransaction?.originId, savedDebt?.debtId);
      expect(localDataSource.updatedTransaction?.frequency, Frequency.oneTime);
      expect(
        localDataSource.updatedTransaction?.generationMode,
        TransactionTypes.generationConverted,
      );
    },
  );

  test(
    'editing an expense into a subscription creates the recurring plan and links the transaction',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );
      final previousTransaction = convertibleExpenseTransaction();
      final request = recurringExpenseRequest(
        draftParty(username: 'Netflix', relationType: FriendConst.friend),
      );

      await repository.updateTransaction(previousTransaction, request);

      expect(savedRecurringTransfert, isNotNull);
      expect(
        savedRecurringTransfert?.recurringTransfertTypeId,
        TransactionTypes.subscriptionCode,
      );
      expect(localDataSource.updatedTransaction, isNotNull);
      expect(
        localDataSource.updatedTransaction?.type,
        TransactionTypes.subscriptionCode,
      );
      expect(
        localDataSource.updatedTransaction?.originId,
        savedRecurringTransfert?.recurringTransfertId,
      );
      expect(
        localDataSource.updatedTransaction?.originOccurrenceDate,
        previousTransaction.date.toIso8601String(),
      );
      expect(
        localDataSource.updatedTransaction?.frequency,
        request.recurringFrequency,
      );
      expect(
        localDataSource.updatedTransaction?.generationMode,
        TransactionTypes.generationConverted,
      );
    },
  );

  test('principal debt update delegates to the debt repository', () async {
    final localDataSource = FakeTransactionLocalDataSource();
    final debtRepository = FakeDebtRepository(
      principalDebt: principalDebtModel(),
    );
    final repository = TransactionRepositoryImpl(
      localDataSource,
      debtRepository: debtRepository,
    );

    await repository.updateTransaction(
      debtPrincipalTransaction(),
      debtUpdateRequest(),
    );

    expect(debtRepository.updatedDebtRequest, isNotNull);
    expect(debtRepository.updatedDebtRequest?.debtId, 'debt-1');
    expect(debtRepository.updatedDebtRequest?.title, 'Updated debt');
    expect(localDataSource.savedTransactions, isEmpty);
  });

  test('principal debt delete delegates to the debt repository', () async {
    final localDataSource = FakeTransactionLocalDataSource();
    final debtRepository = FakeDebtRepository(
      principalDebt: principalDebtModel(),
    );
    final repository = TransactionRepositoryImpl(
      localDataSource,
      debtRepository: debtRepository,
    );

    await repository.deleteTransaction(debtPrincipalTransaction());

    expect(debtRepository.deletedDebtId, 'debt-1');
  });

  test('debt repayment delete delegates to the debt repository', () async {
    final localDataSource = FakeTransactionLocalDataSource();
    final debtRepository = FakeDebtRepository();
    final repository = TransactionRepositoryImpl(
      localDataSource,
      debtRepository: debtRepository,
    );

    await repository.deleteTransaction(debtRepaymentTransaction());

    expect(
      debtRepository.deletedDebtLinkedTransaction?.tid,
      debtRepaymentTransaction().tid,
    );
  });

  test(
    'debt repayment edit stays blocked from the transaction form flow',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      final debtRepository = FakeDebtRepository();
      final repository = TransactionRepositoryImpl(
        localDataSource,
        debtRepository: debtRepository,
      );

      expect(
        () => repository.updateTransaction(
          debtRepaymentTransaction(),
          debtUpdateRequest(),
        ),
        throwsA(
          isA<MessageFailure>().having(
            (failure) => failure.message,
            'message',
            'Debt repayments can only be managed from the debts screen.',
          ),
        ),
      );
    },
  );
}
