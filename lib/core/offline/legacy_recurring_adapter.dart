import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/add_fund/data/models/recurring_funding.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';

import 'legacy_uuid.dart';

RecurringTransfertModel subscriptionAsRecurring(
  SubscriptionModel subscription, {
  RecurringTransfertModel? current,
}) {
  return RecurringTransfertModel(
    recurringTransfertId: subscription.subscriptionId == null
        ? null
        : canonicalLegacyUuid('subscriptions', subscription.subscriptionId!),
    uid: subscription.sid,
    recurringTransfertTypeId: TransactionTypes.subscriptionCode,
    title: subscription.title,
    note: subscription.notes ?? '',
    amount: subscription.amount,
    currency: subscription.currency,
    senderId: current?.senderId ?? subscription.sid,
    beneficiaryId: current?.beneficiaryId ?? '',
    senderWalletId: current?.senderWalletId,
    beneficiaryWalletId: current?.beneficiaryWalletId,
    frequency: subscription.frequency,
    startDate: subscription.startDate,
    nextDueDate: subscription.nextBillingDate,
    endDate: subscription.endDate,
    status:
        subscription.status ??
        current?.status ??
        AppRecurringTransfertState.active,
    executionMode:
        current?.executionMode ?? AppExecutionMode.manualConfirmation,
    reminderEnabled: current?.reminderEnabled ?? true,
    lastGeneratedAt: current?.lastGeneratedAt,
    lastConfirmedAt: current?.lastConfirmedAt,
    createdAt: subscription.createdAt,
  );
}

SubscriptionModel? subscriptionFromRecurring(
  RecurringTransfertModel recurring,
) {
  if (recurring.recurringTransfertTypeId != TransactionTypes.subscriptionCode) {
    return null;
  }
  return SubscriptionModel(
    subscriptionId: recurring.recurringTransfertId,
    sid: recurring.uid,
    title: recurring.title,
    amount: recurring.amount,
    currency: recurring.currency,
    frequency: recurring.frequency,
    startDate: recurring.startDate,
    nextBillingDate: recurring.nextDueDate,
    endDate: recurring.endDate,
    notes: recurring.note,
    createdAt: recurring.createdAt,
    status: recurring.status,
  );
}

RecurringTransfertModel fundingPlanAsRecurring(
  RecurringFundingModel funding, {
  String? walletId,
}) {
  return RecurringTransfertModel(
    recurringTransfertId: canonicalLegacyUuid(
      'recurring_fundings',
      funding.recurringFundingId,
    ),
    uid: funding.uid,
    recurringTransfertTypeId: funding.fundingType == AccountFundingType.salary
        ? TransactionTypes.salaryCode
        : TransactionTypes.otherRecurringIncomeCode,
    title: funding.source,
    note: funding.note ?? '',
    amount: funding.amount,
    currency: funding.currency,
    senderId: '',
    beneficiaryId: funding.uid,
    beneficiaryWalletId: walletId,
    frequency: funding.frequency,
    startDate: funding.startDate,
    nextDueDate: funding.nextFundingDate,
    status: funding.status,
    executionMode: funding.salaryProcessingMode,
    reminderEnabled:
        funding.salaryReminderStatus == SalaryReminderStatus.enabled,
    lastGeneratedAt: funding.lastProcessedAt,
    createdAt: funding.createdAt,
  );
}
