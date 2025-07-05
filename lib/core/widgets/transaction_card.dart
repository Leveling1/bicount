import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String name;
  final String date;
  final String amount;

  const TransactionCard({
    super.key,
    required this.name,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).cardColor,
            width: 0.5, 
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 20,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // Name and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '+ $amount',
            style: const TextStyle(
              color: AppColors.primaryColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
