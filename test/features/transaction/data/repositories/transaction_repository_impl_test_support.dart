import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';

class FakeTransactionLocalDataSource implements TransactionLocalDataSource {
  FakeTransactionLocalDataSource({this.matchingFriend});

  FriendsModel? matchingFriend;
  int createFriendCallCount = 0;
  int findMatchingFriendCallCount = 0;
  final List<FriendsModel> createdFriends = [];
  final List<SavedTransactionRecord> savedTransactions = [];
  UpdatedTransactionRecord? updatedTransaction;

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    createFriendCallCount += 1;
    final createdFriend = FriendsModel(
      sid: 'created-$createFriendCallCount',
      uid: null,
      fid: 'owner-1',
      username: friend.username,
      email: friend.email,
      image: friend.image,
      give: 0,
      receive: 0,
      relationType: FriendConst.getTypeOfFriend(transactionType),
    );
    createdFriends.add(createdFriend);
    return Right(createdFriend);
  }

  @override
  Future<Either<Failure, FriendsModel?>> findMatchingFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    findMatchingFriendCallCount += 1;
    return Right(matchingFriend);
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    String? transactionId,
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
    required int type,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) async {
    savedTransactions.add(
      SavedTransactionRecord(
        title: title,
        senderId: senderId,
        beneficiaryId: beneficiaryId,
        type: type,
        originId: originId,
        originOccurrenceDate: originOccurrenceDate,
        generationMode: generationMode,
      ),
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
    required int type,
    int? frequency,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) async {
    updatedTransaction = UpdatedTransactionRecord(
      previousTransaction: previousTransaction,
      title: title,
      date: date,
      amount: amount,
      category: category,
      currency: currency,
      note: note,
      senderId: senderId,
      beneficiaryId: beneficiaryId,
      image: image,
      type: type,
      frequency: frequency,
      originId: originId,
      originOccurrenceDate: originOccurrenceDate,
      generationMode: generationMode,
    );
    return const Right(null);
  }
}

class SavedTransactionRecord {
  const SavedTransactionRecord({
    required this.title,
    required this.senderId,
    required this.beneficiaryId,
    required this.type,
    required this.originId,
    required this.originOccurrenceDate,
    required this.generationMode,
  });

  final String title;
  final String senderId;
  final String beneficiaryId;
  final int type;
  final String? originId;
  final String? originOccurrenceDate;
  final int? generationMode;
}

class UpdatedTransactionRecord {
  const UpdatedTransactionRecord({
    required this.previousTransaction,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.currency,
    required this.note,
    required this.senderId,
    required this.beneficiaryId,
    required this.image,
    required this.type,
    required this.frequency,
    required this.originId,
    required this.originOccurrenceDate,
    required this.generationMode,
  });

  final TransactionEntity previousTransaction;
  final String title;
  final String date;
  final double amount;
  final int category;
  final String currency;
  final String note;
  final String senderId;
  final String beneficiaryId;
  final String image;
  final int type;
  final int? frequency;
  final String? originId;
  final String? originOccurrenceDate;
  final int? generationMode;
}

class FakeDebtRepository implements DebtRepository {
  FakeDebtRepository({this.principalDebt});

  DebtModel? principalDebt;
  UpdateDebtRequestEntity? updatedDebtRequest;
  String? deletedDebtId;
  TransactionEntity? deletedDebtLinkedTransaction;

  @override
  Future<void> createDebt(DebtModel debt) async {}

  @override
  Future<void> deleteDebt(String debtId) async {
    deletedDebtId = debtId;
  }

  @override
  Future<void> deleteDebtContract(String debtId) async {
    deletedDebtId = debtId;
  }

  @override
  Future<void> deleteDebtLinkedTransaction(
    TransactionEntity transaction,
  ) async {
    deletedDebtLinkedTransaction = transaction;
  }

  @override
  Future<DebtModel?> findDebtById(String debtId) async {
    if (principalDebt?.debtId == debtId) {
      return principalDebt;
    }
    return null;
  }

  @override
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  ) async {
    if (principalDebt?.principalTransactionId == principalTransactionId) {
      return principalDebt;
    }
    return null;
  }

  @override
  Future<void> recordDebtPayment(
    RecordDebtPaymentRequestEntity request,
  ) async {}

  @override
  Future<void> updateDebtContract(UpdateDebtRequestEntity request) async {
    updatedDebtRequest = request;
  }
}

FriendsModel currentUser() {
  return FriendsModel(
    sid: 'user-1',
    uid: 'user-1',
    username: 'Louis',
    image: '',
    email: 'louis@example.com',
    relationType: FriendConst.friend,
  );
}

FriendsModel draftParty({required String username, required int relationType}) {
  return FriendsModel(
    sid: '',
    uid: '',
    username: username,
    image: '',
    email: '',
    relationType: relationType,
  );
}

CreateTransactionRequestEntity recurringExpenseRequest(FriendsModel party) {
  return CreateTransactionRequestEntity(
    name: 'Subscription payment',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 19.99,
    currency: 'USD',
    sender: currentUser(),
    note: '',
    transactionType: TransactionTypes.expenseCode,
    splitMode: TransactionSplitMode.equal,
    splits: [TransactionSplitInputEntity(beneficiary: party)],
    isRecurring: true,
    recurringFrequency: 1,
    recurringTypeId: TransactionTypes.subscriptionCode,
  );
}

CreateTransactionRequestEntity recurringSalaryRequest(
  FriendsModel employer, {
  int executionMode = AppExecutionMode.manualConfirmation,
  bool reminderEnabled = true,
}) {
  return CreateTransactionRequestEntity(
    name: 'Monthly salary',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 1200,
    currency: 'USD',
    sender: employer,
    note: '',
    transactionType: TransactionTypes.incomeCode,
    splitMode: TransactionSplitMode.equal,
    splits: [TransactionSplitInputEntity(beneficiary: currentUser())],
    isRecurring: true,
    recurringFrequency: 1,
    recurringTypeId: TransactionTypes.salaryCode,
    recurringExecutionMode: executionMode,
    recurringReminderEnabled: reminderEnabled,
  );
}

CreateTransactionRequestEntity debtUpdateRequest() {
  return CreateTransactionRequestEntity(
    name: 'Updated debt',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 80,
    currency: 'USD',
    sender: currentUser(),
    note: 'Updated note',
    transactionType: TransactionTypes.expenseCode,
    splitMode: TransactionSplitMode.equal,
    splits: [
      TransactionSplitInputEntity(
        beneficiary: draftParty(
          username: 'Alice',
          relationType: FriendConst.friend,
        ),
      ),
    ],
    isDebt: true,
    debtDueDate: DateTime(2026, 5, 1).toIso8601String(),
    debtExpectedRepaymentAmount: 95,
  );
}

CreateTransactionRequestEntity incomeDebtUpdateRequest() {
  return CreateTransactionRequestEntity(
    name: 'Updated income debt',
    date: DateTime(2026, 4, 11).toIso8601String(),
    totalAmount: 80,
    currency: 'USD',
    sender: draftParty(username: 'Employer', relationType: FriendConst.friend),
    note: 'Updated income note',
    transactionType: TransactionTypes.incomeCode,
    splitMode: TransactionSplitMode.equal,
    splits: [
      TransactionSplitInputEntity(
        beneficiary: currentUser(),
      ),
    ],
    isDebt: true,
    debtDueDate: DateTime(2026, 5, 1).toIso8601String(),
    debtExpectedRepaymentAmount: 95,
  );
}

TransactionEntity debtPrincipalTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'principal-1',
    gtid: 'group-1',
    name: 'Debt',
    type: TransactionTypes.debtCode,
    date: DateTime(2026, 4, 10),
    amount: 100,
    currency: 'USD',
    originId: 'debt-1',
    sender: 'user-1',
    beneficiary: 'friend-1',
    note: '',
  );
}

TransactionEntity debtRepaymentTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'repayment-1',
    gtid: 'group-2',
    name: 'Repayment',
    type: TransactionTypes.debtCode,
    date: DateTime(2026, 4, 12),
    amount: 20,
    currency: 'USD',
    originId: 'debt-1',
    sender: 'friend-1',
    beneficiary: 'user-1',
    note: '',
  );
}

TransactionEntity convertibleExpenseTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'expense-1',
    gtid: 'group-expense-1',
    name: 'Lunch',
    type: TransactionTypes.expenseCode,
    date: DateTime(2026, 4, 9),
    amount: 45,
    currency: 'USD',
    sender: 'user-1',
    beneficiary: 'friend-1',
    note: 'Team lunch',
  );
}

TransactionEntity convertibleIncomeTransaction() {
  return TransactionEntity(
    uid: 'user-1',
    tid: 'income-1',
    gtid: 'group-income-1',
    name: 'Consulting',
    type: TransactionTypes.incomeCode,
    date: DateTime(2026, 4, 9),
    amount: 1500,
    currency: 'USD',
    sender: 'friend-1',
    beneficiary: 'user-1',
    note: 'Monthly consulting',
  );
}

DebtModel principalDebtModel() {
  return DebtModel(
    debtId: 'debt-1',
    createdBy: 'user-1',
    lenderId: 'user-1',
    borrowerId: 'friend-1',
    principalTransactionId: 'principal-1',
    title: 'Debt',
    currency: 'USD',
    principalAmount: 100,
    expectedRepaymentAmount: 100,
    remainingAmount: 100,
    dueDate: DateTime(2026, 5, 1).toIso8601String(),
  );
}
