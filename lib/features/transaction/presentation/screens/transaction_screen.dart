import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../data/models/transaction.model.dart';
import '../../domain/entities/transaction_detail_args.dart';
import '../bloc/transaction_bloc.dart';
import 'detail_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  final MainEntity data;
  final bool showSearchBar;
  final TextEditingController searchController;
  final int selectedIndexTransaction;

  const TransactionScreen({
    super.key,
    required this.data,
    this.showSearchBar = false,
    required this.searchController,
    required this.selectedIndexTransaction,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  late List<TransactionModel> transactions = [];

  Map<String, List<TransactionModel>> groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    Map<String, List<TransactionModel>> grouped = {};

    for (var tx in transactions) {
      final DateTime date = DateTime.parse(tx.createdAt!);
      final now = DateTime.now();

      String key;
      if (isSameDate(date, now)) {
        key = 'Today';
      } else if (isSameDate(date, now.subtract(Duration(days: 1)))) {
        key = 'Yesterday';
      } else {
        key = formatDate(date);
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }

    return grouped;
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showSearchBar) {
      widget.searchController.clear();
    }
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionCreated) {
          NotificationHelper.showSuccessNotification(context, state.toString());
        } else if (state is TransactionError) {
          NotificationHelper.showFailureNotification(
            context,
            state.failure.message,
          );
        }
      },
      builder: (context, state) {
        transactions = widget.data.transactions;
        List<TransactionModel> filteredTransactions =
            widget.selectedIndexTransaction == 0 && widget.searchController.text.isEmpty
            ? transactions
            : widget.selectedIndexTransaction == 0 && widget.searchController.text.isNotEmpty
            ? transactions
                  .where(
                    (tx) => tx.name.toLowerCase().contains(
                      widget.searchController.text.toLowerCase(),
                    ),
                  )
                  .toList()
            : widget.selectedIndexTransaction != 0 && widget.searchController.text.isNotEmpty
            ? transactions
                  .where(
                    (tx) =>
                        tx.name.toLowerCase().contains(
                          widget.searchController.text.toLowerCase(),
                        ) &&
                        tx.type ==
                            TransactionTypes.allTypesInt[widget.selectedIndexTransaction],
                  )
                  .toList()
            : TransactionTypes.allTypes[widget.selectedIndexTransaction] ==
                  TransactionTypes.allTypes[5]
            ? transactions
                  .where((tx) => tx.category == TransactionTypes.personalIncome)
                  .toList()
            : TransactionTypes.allTypes[widget.selectedIndexTransaction] ==
                  TransactionTypes.allTypes[6]
            ? transactions
                  .where((tx) => tx.category == TransactionTypes.companyIncome)
                  .toList()
            : transactions
                  .where(
                    (tx) =>
                        tx.type ==
                        TransactionTypes.allTypesInt[widget.selectedIndexTransaction],
                  )
                  .toList();

        final grouped = groupTransactionsByDate(filteredTransactions);

        return transactions.isNotEmpty
            ? Column(
                children: [
                
                  filteredTransactions.isNotEmpty
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingMedium,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(
                                context,
                              ).copyWith(scrollbars: false),
                              child: ListView(
                                padding: EdgeInsets.only(top: 15, bottom: 50.h),
                                children: grouped.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      ...entry.value.map((tx) {
                                        TransactionEntity transaction =
                                            TransactionEntity.fromTransaction(
                                              tx,
                                            );
                                        return TransactionCard(
                                          transaction: transaction,
                                          onTap: () {
                                            showCustomBottomSheet(
                                              context: context,
                                              minHeight: 0.95,
                                              color: null,
                                              child: DetailTransactionScreen(
                                                transaction:
                                                    TransactionDetailArgs(
                                                      user: widget.data.user,
                                                      transactionDetail:
                                                          transaction,
                                                      friends:
                                                          widget.data.friends,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: const Center(
                            child: Text('No transactions found'),
                          ),
                        ),
                ],
              )
            : const Center(child: Text('No transactions found'));
      },
    );
  }
}
