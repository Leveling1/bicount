import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_handler.dart';
import 'package:flutter/material.dart';

void openTransactionSheet(
  BuildContext context,
  MainEntity data, {
  TransactionHandlerInitialType initialType =
      TransactionHandlerInitialType.expense,
  bool showTypeSelector = true,
}) {
  showCustomBottomSheet(
    context: context,
    minHeight: 0.95,
    color: null,
    scrollEnabled: false,
    child: TransactionHandler(
      user: data.user,
      friends: data.friends,
      initialType: initialType,
      showTypeSelector: showTypeSelector,
    ),
  );
}
