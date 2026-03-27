import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/utils/date_format_utils.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';
import 'package:bicount/features/add_fund/presentation/bloc/add_fund_bloc.dart';
import 'package:flutter/material.dart';

void hydrateAccountFundingForm({
  required AccountFundingModel funding,
  required TextEditingController sourceController,
  required TextEditingController dateController,
  required TextEditingController amountController,
  required TextEditingController currencyController,
  required TextEditingController noteController,
  required ValueChanged<int> onFundingType,
}) {
  final parsedDate = DateTime.tryParse(funding.date);
  sourceController.text = funding.source;
  dateController.text = parsedDate == null
      ? funding.date
      : formatedDateTimeNumericFullYear(parsedDate);
  amountController.text = funding.amount.toString();
  currencyController.text = funding.currency;
  noteController.text = funding.note ?? '';
  onFundingType(funding.fundingType);
}

AddAccountFundingEntity buildAccountFundingPayload({
  required AccountFundingModel? initialFunding,
  required String source,
  required String amount,
  required String currency,
  required String note,
  required String date,
  required int fundingType,
  required bool isRecurring,
  required int? frequency,
}) {
  return AddAccountFundingEntity(
    fundingId: initialFunding?.fundingId,
    source: source,
    amount: double.parse(amount),
    currency: currency,
    note: note,
    date: date,
    category: initialFunding?.category ?? Constants.personal,
    sid: initialFunding?.sid,
    fundingType: fundingType,
    isRecurring: isRecurring,
    frequency: frequency,
  );
}

AddFundEvent buildAddFundEvent({
  required AccountFundingModel? initialFunding,
  required String source,
  required String amount,
  required String currency,
  required String note,
  required String date,
  required int fundingType,
  required bool isRecurring,
  required int? frequency,
}) {
  final payload = buildAccountFundingPayload(
    initialFunding: initialFunding,
    source: source,
    amount: amount,
    currency: currency,
    note: note,
    date: date,
    fundingType: fundingType,
    isRecurring: isRecurring,
    frequency: frequency,
  );

  return initialFunding != null
      ? AddFundUpdated(data: payload)
      : AddFundSubmitted(data: payload);
}
