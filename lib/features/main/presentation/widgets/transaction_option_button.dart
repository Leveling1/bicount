import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionOptionButton extends StatelessWidget {
  const TransactionOptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: () => context.push('/debts'),
      icon: Icons.dashboard,
    );
  }
}
