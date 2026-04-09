import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:flutter/material.dart';

/// Placeholder for the recurring transferts home card.
/// Will be wired to RecurringTransfertModel data in a follow-up pass.
class HomeRecurringFundingsStatusCard extends StatelessWidget {
  const HomeRecurringFundingsStatusCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final MainEntity data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: wire to RecurringTransfertModel dashboard
    return const SizedBox.shrink();
  }
}
