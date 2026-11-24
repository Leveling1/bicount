import 'package:bicount/core/widgets/transaction_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, _) =>
          SkeletonItem(child: const TransactionCardSkeleton()),
    );
  }
}
