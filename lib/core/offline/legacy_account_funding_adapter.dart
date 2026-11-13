import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

import 'legacy_uuid.dart';

/// Keeps the existing funding form contract while money lives in transactions.
TransactionModel fundingAsTransaction(AccountFundingModel funding) {
  return TransactionModel(
    tid: canonicalLegacyUuid('account_funding', funding.fundingId),
    gtid: canonicalLegacyUuid('account_funding', funding.fundingId),
    uid: funding.sid,
    name: funding.source,
    type: TransactionTypes.incomeCode,
    senderId: funding.sid,
    beneficiaryId: funding.sid,
    beneficiaryWalletId: funding.walletId,
    date: funding.date,
    note: funding.note ?? '',
    amount: funding.amount,
    currency: funding.currency,
    referenceCurrencyCode: funding.referenceCurrencyCode,
    convertedAmount: funding.convertedAmount,
    amountCdf: funding.amountCdf,
    rateToCdf: funding.rateToCdf,
    fxRateDate: funding.fxRateDate,
    fxSnapshotId: funding.fxSnapshotId,
    category: funding.category,
    createdAt: funding.createdAt,
    generationMode: TransactionTypes.generationOneTime,
  );
}

AccountFundingModel? fundingFromTransaction(TransactionModel transaction) {
  if (transaction.type != TransactionTypes.incomeCode ||
      transaction.senderId != transaction.uid ||
      transaction.beneficiaryId != transaction.uid) {
    return null;
  }
  return AccountFundingModel(
    fundingId: transaction.tid,
    sid: transaction.uid,
    amount: transaction.amount,
    currency: transaction.currency,
    walletId: transaction.beneficiaryWalletId,
    referenceCurrencyCode: transaction.referenceCurrencyCode,
    convertedAmount: transaction.convertedAmount,
    amountCdf: transaction.amountCdf,
    rateToCdf: transaction.rateToCdf,
    fxRateDate: transaction.fxRateDate,
    fxSnapshotId: transaction.fxSnapshotId,
    category: transaction.category ?? 0,
    fundingType: AccountFundingType.other,
    source: transaction.name,
    note: transaction.note,
    date: transaction.date,
    createdAt: transaction.createdAt,
  );
}
