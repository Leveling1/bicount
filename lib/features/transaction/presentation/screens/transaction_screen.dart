import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/transaction_bloc.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedIndex = index;
      });
    });
  }

  final List<Map<String, dynamic>> transactions = [
    {
      "name": "Esther Howard",
      "datetime": DateTime(2024, 6, 22, 12, 48),
      "amount": 320,
      "type": "income",
      "image": "assets/memoji/memoji_1.png",
    },
    {
      "name": "Cameron Williamson",
      "datetime": DateTime(2024, 6, 22, 9, 15),
      "amount": 150,
      "type": "expense",
      "image": "assets/memoji/memoji_2.png",
    },
    {
      "name": "Savannah Nguyen",
      "datetime": DateTime(2024, 6, 24, 18, 2),
      "amount": 470,
      "type": "income",
      "image": "assets/memoji/memoji_3.png",
    },
    {
      "name": "Ralph Edwards",
      "datetime": DateTime(2024, 6, 22, 14, 20),
      "amount": 210,
      "type": "expense",
      "image": "assets/memoji/memoji_4.png",
    },
    {
      "name": "Jenny Wilson",
      "datetime": DateTime(2024, 6, 26, 11, 42),
      "amount": 380,
      "type": "income",
      "image": "assets/memoji/memoji_5.png",
    },
    {
      "name": "Dianne Russell",
      "datetime": DateTime(2024, 6, 27, 16, 30),
      "amount": 550,
      "type": "expense",
      "image": "assets/memoji/memoji_6.png",
    },
    {
      "name": "Floyd Miles",
      "datetime": DateTime(2024, 6, 28, 20, 18),
      "amount": 120,
      "type": "income",
      "image": "assets/memoji/memoji_7.png",
    },
    {
      "name": "Bessie Cooper",
      "datetime": DateTime(2024, 6, 29, 13, 55),
      "amount": 290,
      "type": "expense",
      "image": "assets/memoji/memoji_1.png",
    },
    {
      "name": "Wade Warren",
      "datetime": DateTime(2024, 6, 30, 10, 10),
      "amount": 430,
      "type": "income",
      "image": "assets/memoji/memoji_2.png",
    },
    {
      "name": "Kristin Watson",
      "datetime": DateTime(2024, 7, 1, 8, 25),
      "amount": 215,
      "type": "expense",
      "image": "assets/memoji/memoji_3.png",
    },
    {
      "name": "Guy Hawkins",
      "datetime": DateTime(2024, 7, 2, 19, 45),
      "amount": 175,
      "type": "income",
      "image": "assets/memoji/memoji_4.png",
    },
    {
      "name": "Ronald Richards",
      "datetime": DateTime(2024, 7, 3, 15, 0),
      "amount": 340,
      "type": "expense",
      "image": "assets/memoji/memoji_5.png",
    },
    {
      "name": "Courtney Henry",
      "datetime": DateTime(2024, 7, 4, 12, 12),
      "amount": 275,
      "type": "income",
      "image": "assets/memoji/memoji_6.png",
    },
    {
      "name": "Kathryn Murphy",
      "datetime": DateTime(2024, 7, 5, 17, 33),
      "amount": 360,
      "type": "expense",
      "image": "assets/memoji/memoji_7.png",
    },
    {
      "name": "Brooklyn Simmons",
      "datetime": DateTime(2024, 7, 6, 14, 20),
      "amount": 390,
      "type": "income",
      "image": "assets/memoji/memoji_1.png",
    },
    {
      "name": "Eleanor Pena",
      "datetime": DateTime(2024, 7, 7, 11, 8),
      "amount": 460,
      "type": "expense",
      "image": "assets/memoji/memoji_2.png",
    },
    {
      "name": "Cody Fisher",
      "datetime": DateTime(2024, 7, 8, 9, 55),
      "amount": 305,
      "type": "income",
      "image": "assets/memoji/memoji_3.png",
    },
    {
      "name": "Arlene McCoy",
      "datetime": DateTime(2024, 7, 9, 18, 44),
      "amount": 255,
      "type": "expense",
      "image": "assets/memoji/memoji_4.png",
    },
    {
      "name": "Jerome Bell",
      "datetime": DateTime(2024, 7, 10, 13, 21),
      "amount": 495,
      "type": "income",
      "image": "assets/memoji/memoji_5.png",
    },
    {
      "name": "Annette Black",
      "datetime": DateTime(2024, 7, 11, 10, 37),
      "amount": 185,
      "type": "expense",
      "image": "assets/memoji/memoji_6.png",
    },
  ];

  Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(
    List<Map<String, dynamic>> transactions,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var tx in transactions) {
      final DateTime date = tx['datetime'];
      final now = DateTime.now();

      String key;
      if (isSameDate(date, now)) {
        key = 'Today';
      } else if (isSameDate(date, now.subtract(Duration(days: 1)))) {
        key = 'Yesterday';
      } else {
        key = "${date.day}/${date.month}/${date.year}";
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
    final grouped = groupTransactionsByDate(transactions);
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Column(
          children: [
            TransactionFilterChips(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
            Expanded(
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map(
                          (tx) => TransactionCard(
                            name: tx["name"],
                            date: DateFormat.Hm().format(tx["datetime"]),
                            amount: tx["amount"].toString(),
                            type: tx["type"],
                            image: tx["image"],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
