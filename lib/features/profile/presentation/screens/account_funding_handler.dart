import 'package:bicount/features/profile/presentation/widgets/account_funding_fields.dart';
import 'package:flutter/material.dart';

class AccountFundingHandler extends StatefulWidget {
  const AccountFundingHandler({super.key});

  @override
  State<AccountFundingHandler> createState() => _AccountFundingHandlerState();
}

class _AccountFundingHandlerState extends State<AccountFundingHandler> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Add funds to your account',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        AccountFundingForm(),
      ],
    );
  }
}
