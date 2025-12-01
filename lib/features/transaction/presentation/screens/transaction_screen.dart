import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
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

  const TransactionScreen({
    super.key,
    required this.data,
    this.showSearchBar = false,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedIndex = index;
      });
    });
  }

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
      _searchController.clear();
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
            _selectedIndex == 0 && _searchController.text.isEmpty
            ? transactions
            : _selectedIndex == 0 && _searchController.text.isNotEmpty
            ? transactions
                  .where(
                    (tx) => tx.name.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
                  )
                  .toList()
            : _selectedIndex != 0 && _searchController.text.isNotEmpty
            ? transactions
                  .where(
                    (tx) =>
                        tx.name.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ) &&
                        tx.type ==
                            TransactionTypes.allTypes[_selectedIndex]
                                .toLowerCase(),
                  )
                  .toList()
            : TransactionTypes.allTypes[_selectedIndex] ==
                  TransactionTypes.allTypes[4]
            ? transactions
                  .where((tx) => tx.category == TransactionTypes.personalIncome)
                  .toList()
            : TransactionTypes.allTypes[_selectedIndex] ==
                  TransactionTypes.allTypes[5]
            ? transactions
                  .where((tx) => tx.category == TransactionTypes.companyIncome)
                  .toList()
            : transactions
                  .where(
                    (tx) =>
                        tx.type ==
                        TransactionTypes.allTypes[_selectedIndex].toLowerCase(),
                  )
                  .toList();

        final grouped = groupTransactionsByDate(filteredTransactions);

        return transactions.isNotEmpty
            ? Column(
                children: [
                  SmoothInsert(
                    visible: widget.showSearchBar,
                    verticalMargin: AppDimens.paddingSmall,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingMedium,
                      ),
                      child: CustomSearchField(
                        onChanged: (value) {
                          setState(() {
                            _searchController.text = value;
                          });
                        },
                      ),
                    ),
                  ),
                  TransactionFilterChips(
                    selectedIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    filters: TransactionTypes.allTypes,
                  ),
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
                                              child: DetailTransaction(
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
