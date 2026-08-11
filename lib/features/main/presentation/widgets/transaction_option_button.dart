import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shortcut button shown only on the Transaction tab. It only becomes
/// visible once at least one debt, salary, recurring income, or
/// subscription/recurring charge has been recorded. With exactly one of
/// those present it jumps straight to the matching screen; with several it
/// opens a control-center sheet listing only the ones that apply.
class TransactionOptionButton extends StatelessWidget {
  const TransactionOptionButton({
    super.key,
    required this.debts,
    required this.recurringTransferts,
  });

  final List<DebtModel> debts;
  final List<RecurringTransfertModel> recurringTransferts;

  bool get _hasDebts => debts.isNotEmpty;

  bool get _hasSalary => recurringTransferts.any(
    (item) => item.recurringTransfertTypeId == TransactionTypes.salaryCode,
  );

  // Salary is intentionally excluded here: it already has its own entry.
  bool get _hasRecurringIncome => recurringTransferts.any(
    (item) =>
        item.recurringTransfertTypeId ==
        TransactionTypes.otherRecurringIncomeCode,
  );

  // Subscriptions and other recurring charges share the same destination
  // screen, so they are counted together as a single entry.
  bool get _hasRecurringCharges => recurringTransferts.any(
    (item) =>
        item.recurringTransfertTypeId == TransactionTypes.subscriptionCode ||
        item.recurringTransfertTypeId ==
            TransactionTypes.otherRecurringExpenseCode,
  );

  List<_TransactionOption> _buildOptions(BuildContext context) {
    return [
      if (_hasDebts)
        _TransactionOption(
          label: context.l10n.debtScreenTitle,
          icon: Icons.receipt_long_outlined,
          route: '/debts',
        ),
      if (_hasSalary)
        _TransactionOption(
          label: context.l10n.salaryTrackingTitle,
          icon: Icons.payments_outlined,
          route: '/salary',
        ),
      if (_hasRecurringIncome)
        _TransactionOption(
          label: context.l10n.recurringIncomesTitle,
          icon: Icons.trending_up,
          route: '/recurring-incomes',
        ),
      if (_hasRecurringCharges)
        _TransactionOption(
          label: context.l10n.recurringChargesTitle,
          icon: Icons.subscriptions_outlined,
          route: '/subscriptions',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions(context);

    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomIconButton(
      onPressed: () {
        if (options.length == 1) {
          context.push(options.first.route);
          return;
        }
        _showControlCenter(context, options);
      },
      icon: Icons.dashboard,
    );
  }

  void _showControlCenter(
    BuildContext context,
    List<_TransactionOption> options,
  ) {
    showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.transactionControlCenterTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...options.map(
            (option) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(option.icon),
              title: Text(option.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                context.push(option.route);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionOption {
  const _TransactionOption({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
