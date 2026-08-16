import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

import '../../../main/data/models/friends.model.dart';

class TransactionDetailArgs {
  final UserModel user;
  final TransactionEntity transactionDetail;
  final List<FriendsModel> friends;
  final List<DebtModel> debts;

  /// [debts] is required on purpose. It used to default to an empty list, and
  /// a caller that forgot it silently lost every debt detail — the screen
  /// still rendered, just without the repayment rows or the "view debt"
  /// button. Making it explicit turns that omission into a compile error.
  TransactionDetailArgs({
    required this.user,
    required this.transactionDetail,
    required this.friends,
    required this.debts,
  });
}
