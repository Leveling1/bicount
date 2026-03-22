import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/smooth_switcher.dart';
import 'package:bicount/core/services/title_animated_switcher.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/profile/presentation/widgets/account_funding_fields.dart';
import 'package:bicount/features/transaction/presentation/widgets/subscription_form.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form.dart';
import 'package:flutter/material.dart';

import '../widgets/segment_control.dart';

class TransactionHandler extends StatefulWidget {
  const TransactionHandler({
    super.key,
    required this.user,
    required this.friends,
  });

  final UserModel? user;
  final List<FriendsModel> friends;

  @override
  State<TransactionHandler> createState() => _TransactionHandlerState();
}

class _TransactionHandlerState extends State<TransactionHandler> {
  late final SegmentedControlController _segmentedType;

  @override
  void initState() {
    super.initState();
    _segmentedType = SegmentedControlController();
    _segmentedType.addListener(_onSegmentChanged);
  }

  @override
  void dispose() {
    _segmentedType.removeListener(_onSegmentChanged);
    _segmentedType.dispose();
    super.dispose();
  }

  void _onSegmentChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _segmentedType.selectedIndex;
    final title = switch (selectedIndex) {
      0 => context.l10n.transactionAddTitle,
      1 => context.l10n.transactionNewSubscriptionTitle,
      _ => context.l10n.transactionAddFundsTitle,
    };

    return Column(
      children: [
        TitleAnimatedSwitcher(
          child: Text(
            title,
            key: ValueKey(selectedIndex),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedControlWidget(controller: _segmentedType),
        const SizedBox(height: 16),
        SmoothSwitcher(
          child: switch (selectedIndex) {
            0 => TransferForm(user: widget.user, friends: widget.friends),
            1 => const SubscriptionForm(),
            _ => const AccountFundingForm(),
          },
        ),
      ],
    );
  }
}
