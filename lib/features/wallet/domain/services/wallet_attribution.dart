import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';

List<({bool sender, String id})> walletSides(
  MainEntity data,
  TransactionEntity transaction,
) {
  final uid = data.user.uid;
  final ids = const TransactionParticipantIdentityService()
      .currentUserParticipantIds(currentUserId: uid, friends: data.friends);
  final self = transaction.sender == transaction.beneficiary;
  final principal = WalletModel.principalId(uid);
  return [
    if (ids.contains(transaction.sender) &&
        (!self || !TransactionTypes.isIncomeType(transaction.type)))
      (sender: true, id: transaction.senderWalletId ?? principal),
    if (ids.contains(transaction.beneficiary) &&
        (!self || !TransactionTypes.isExpenseType(transaction.type)))
      (sender: false, id: transaction.beneficiaryWalletId ?? principal),
  ];
}
