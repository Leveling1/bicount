import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:flutter/material.dart';

void hydrateSubscriptionForm({
  required SubscriptionModel subscription,
  required TextEditingController nameController,
  required TextEditingController amountController,
  required TextEditingController currencyController,
  required TextEditingController frequencyController,
  required TextEditingController startDateController,
  required TextEditingController nextBillingDateController,
  required TextEditingController noteController,
  required ValueChanged<bool> onDifferentDate,
}) {
  final startDate = DateTime.tryParse(subscription.startDate);
  final nextBillingDate = DateTime.tryParse(subscription.nextBillingDate);
  nameController.text = subscription.title;
  amountController.text = subscription.amount.toString();
  currencyController.text = subscription.currency;
  frequencyController.text = '${subscription.frequency}';
  startDateController.text = startDate == null
      ? subscription.startDate
      : formatedDateTimeNumericFullYear(startDate);
  nextBillingDateController.text = nextBillingDate == null
      ? subscription.nextBillingDate
      : formatedDateTimeNumericFullYear(nextBillingDate);
  noteController.text = subscription.notes ?? '';
  onDifferentDate(_hasDifferentBillingDate(subscription));
}

SubscriptionEntity buildSubscriptionPayload({
  required SubscriptionModel? initialSubscription,
  required String title,
  required String amount,
  required String currency,
  required String frequency,
  required String startDate,
  required String nextBillingDate,
  required String note,
}) {
  final now = DateTime.now();
  return SubscriptionEntity(
    subscriptionId: initialSubscription?.subscriptionId,
    title: title,
    amount: _parseAmountInput(amount),
    currency: currency,
    frequency: int.parse(frequency),
    startDate: resolveFormDateToIso(startDate),
    nextBillingDate: resolveFormDateToIso(nextBillingDate),
    note: note,
    status: initialSubscription == null
        ? SubscriptionConst.active
        : SubscriptionConst.normalize(initialSubscription.status),
    createdAt: initialSubscription?.createdAt ?? now.toIso8601String(),
    category: initialSubscription?.category ?? Constants.personal,
    sid: initialSubscription?.sid,
    endDate: initialSubscription?.endDate,
  );
}

bool _hasDifferentBillingDate(SubscriptionModel subscription) {
  final start = parseFormDate(subscription.startDate);
  final nextBilling = parseFormDate(subscription.nextBillingDate);
  if (start == null || nextBilling == null) {
    return subscription.nextBillingDate != subscription.startDate;
  }

  return start.year != nextBilling.year ||
      start.month != nextBilling.month ||
      start.day != nextBilling.day;
}

double _parseAmountInput(String rawValue) {
  return double.parse(rawValue.replaceAll(' ', '').replaceAll(',', '.'));
}
