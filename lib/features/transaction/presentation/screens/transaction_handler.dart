import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/profile/presentation/screens/account_funding_handler.dart';
import 'package:bicount/features/profile/presentation/widgets/account_funding_fields.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_fields.dart';
import 'package:flutter/material.dart';

import '../widgets/segment_control.dart';

class TransactionHandler extends StatefulWidget {
  final UserModel? user;
  final List<FriendsModel> friends;
  const TransactionHandler({
    super.key,
    required this.user,
    required this.friends,
  });

  @override
  State<TransactionHandler> createState() => _TransactionHandlerState();
}

class _TransactionHandlerState extends State<TransactionHandler> {
  final TextEditingController _type = TextEditingController();

  late SegmentedControlController _segmentedType;

  @override
  void initState() {
    super.initState();
    _segmentedType = SegmentedControlController();
    _segmentedType.addListener(_onSegmentChanged);
    _type.text = _segmentedType.selectedValue;
  }

  @override
  void dispose() {
    _segmentedType.removeListener(_onSegmentChanged);
    _segmentedType.dispose();
    super.dispose();
  }

  void _onSegmentChanged() {
    setState(() {
      _type.text = _segmentedType.selectedValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _type.text == TransactionTypes.transferText
              ? 'Add transaction'
              : _type.text == TransactionTypes.subscriptionText
              ? 'New subscription'
              : 'Add funds to your account',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        SegmentedControlWidget(controller: _segmentedType),
        const SizedBox(height: 16),
        _type.text == TransactionTypes.transferText
            ? TransferForm(user: widget.user, friends: widget.friends)
            : _type.text == TransactionTypes.subscriptionText
            ? Text('Subscription Fields')
            : AccountFundingForm(),
      ],
    );
  }
}
