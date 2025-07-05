import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final List<Map<String, String>> transactions = [
    {"name": "Esther Howard", "date": "Sun 22 at 12:48", "amount": "320"},
    {"name": "Cameron Williamson", "date": "Mon 23 at 09:15", "amount": "150"},
    {"name": "Savannah Nguyen", "date": "Tue 24 at 18:02", "amount": "470"},
    {"name": "Ralph Edwards", "date": "Wed 25 at 14:20", "amount": "210"},
    {"name": "Jenny Wilson", "date": "Thu 26 at 11:42", "amount": "380"},
    {"name": "Dianne Russell", "date": "Fri 27 at 16:30", "amount": "550"},
    {"name": "Floyd Miles", "date": "Sat 28 at 20:18", "amount": "120"},
    {"name": "Bessie Cooper", "date": "Sun 29 at 13:55", "amount": "290"},
    {"name": "Wade Warren", "date": "Mon 30 at 10:10", "amount": "430"},
    {"name": "Kristin Watson", "date": "Tue 1 at 08:25", "amount": "215"},
    {"name": "Guy Hawkins", "date": "Wed 2 at 19:45", "amount": "175"},
    {"name": "Ronald Richards", "date": "Thu 3 at 15:00", "amount": "340"},
    {"name": "Courtney Henry", "date": "Fri 4 at 12:12", "amount": "275"},
    {"name": "Kathryn Murphy", "date": "Sat 5 at 17:33", "amount": "360"},
    {"name": "Brooklyn Simmons", "date": "Sun 6 at 14:20", "amount": "390"},
    {"name": "Eleanor Pena", "date": "Mon 7 at 11:08", "amount": "460"},
    {"name": "Cody Fisher", "date": "Tue 8 at 09:55", "amount": "305"},
    {"name": "Arlene McCoy", "date": "Wed 9 at 18:44", "amount": "255"},
    {"name": "Jerome Bell", "date": "Thu 10 at 13:21", "amount": "495"},
    {"name": "Annette Black", "date": "Fri 11 at 10:37", "amount": "185"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColorDark,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.cardColorDark,
        elevation: 0,
        title: Text(
          'Transaction',
          style: TextStyle(
        color: AppColors.backgroundColorLight,
        fontSize: AppDimens.textSizeExtraLarge,
        fontWeight: FontWeight.bold
          ),
        ),
        scrolledUnderElevation: 0, // Empêche le changement de couleur au scroll
        surfaceTintColor: Colors.transparent, // Garde la couleur de fond inchangée
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionCard(
                name: transaction["name"]!,
                date: transaction["date"]!,
                amount: transaction["amount"]!,
              );
            },
          );
        },
      ),
    );
  }
}
