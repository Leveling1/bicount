import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

enum TransactionSplitMode { equal, percentage, customAmount }

extension TransactionSplitModeLabel on TransactionSplitMode {
  String get label {
    switch (this) {
      case TransactionSplitMode.equal:
        return 'Equal';
      case TransactionSplitMode.percentage:
        return 'Percentage';
      case TransactionSplitMode.customAmount:
        return 'Custom';
    }
  }

  String get helperText {
    switch (this) {
      case TransactionSplitMode.equal:
        return 'Bicount splits the total amount equally for every beneficiary.';
      case TransactionSplitMode.percentage:
        return 'Set a percentage for each beneficiary. The total must reach 100%.';
      case TransactionSplitMode.customAmount:
        return 'Set the exact amount received by each beneficiary.';
    }
  }
}

class TransactionSplitInputEntity {
  const TransactionSplitInputEntity({
    required this.beneficiary,
    this.percentage,
    this.amount,
  });

  final FriendsModel beneficiary;
  final double? percentage;
  final double? amount;
}

class ResolvedTransactionSplitEntity {
  const ResolvedTransactionSplitEntity({
    required this.beneficiary,
    required this.amount,
    this.percentage,
  });

  final FriendsModel beneficiary;
  final double amount;
  final double? percentage;
}

class CreateTransactionRequestEntity {
  const CreateTransactionRequestEntity({
    required this.name,
    required this.date,
    required this.totalAmount,
    required this.currency,
    required this.sender,
    required this.note,
    required this.transactionType,
    required this.splitMode,
    required this.splits,
    this.category = Constants.personal,
    this.isRecurring = false,
    this.recurringFrequency,
    this.recurringTypeId,
  });

  final String name;
  final String date;
  final double totalAmount;
  final String currency;
  final FriendsModel sender;
  final String note;
  final int transactionType;
  final TransactionSplitMode splitMode;
  final List<TransactionSplitInputEntity> splits;
  final int category;

  /// When true the transaction is also registered as a recurring template.
  final bool isRecurring;

  /// Frequency constant from [Frequency] (weekly, monthly, …).
  final int? recurringFrequency;

  /// Type id from [RecurringTransfertType].
  final int? recurringTypeId;
}
