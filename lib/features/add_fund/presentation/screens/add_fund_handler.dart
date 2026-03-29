import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/add_fund/presentation/widgets/account_funding_form.dart';
import 'package:flutter/material.dart';

class AccountFundingHandler extends StatelessWidget {
  const AccountFundingHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.transactionAddFundsTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const AccountFundingForm(),
      ],
    );
  }
}
