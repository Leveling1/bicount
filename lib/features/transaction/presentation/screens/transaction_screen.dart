import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../data/models/transaction.model.dart';
import '../bloc/transaction_bloc.dart';

class TransactionScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  const TransactionScreen({super.key, required this.transactions});

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

  final List<TransactionModel> transactions = [];

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

  final List<String> filters = ['All', 'Income', 'expense', 'Transfer'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionCreated) {
          NotificationHelper.showSuccessNotification(context, state.toString());
        } else if (state is TransactionError) {
          NotificationHelper.showFailureNotification(context, state.failure.message);
        }
      },
      builder: (context, state) {
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
                        tx.type == filters[_selectedIndex].toLowerCase(),
                  )
                  .toList()
            : transactions
                  .where(
                    (tx) => tx.type == filters[_selectedIndex].toLowerCase(),
                  )
                  .toList();

        final grouped = groupTransactionsByDate(filteredTransactions);

        return transactions.isNotEmpty
            ? Column(
                children: [
                  CustomSearchField(
                    onChanged: (value) {
                      setState(() {
                        _searchController.text = value;
                      });
                    },
                  ),
                  TransactionFilterChips(
                    selectedIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    filters: filters,
                  ),
                  filteredTransactions.isNotEmpty
                      ? Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView(
                              children: grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    ...entry.value.map((tx) {
                                      TransactionEntity transaction = TransactionEntity.fromTransaction(tx);
                                      return TransactionCard(
                                        transaction: transaction,
                                      );
                                    }),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
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
            : Expanded(
                child: const Center(child: Text('No transactions found')),
              );
      },
    );
  }
}
