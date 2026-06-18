import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/smooth_switcher.dart';
import 'package:bicount/core/services/title_animated_switcher.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/presentation/widgets/expense_form.dart';
import 'package:bicount/features/transaction/presentation/widgets/income_form.dart';
import 'package:flutter/material.dart';

import '../widgets/segment_control.dart';

enum TransactionHandlerInitialType { expense, income }

class TransactionHandler extends StatefulWidget {
  const TransactionHandler({
    super.key,
    required this.user,
    required this.friends,
    this.initialType = TransactionHandlerInitialType.expense,
    this.showTypeSelector = true,
  });

  final UserModel? user;
  final List<FriendsModel> friends;
  final TransactionHandlerInitialType initialType;
  final bool showTypeSelector;

  @override
  State<TransactionHandler> createState() => _TransactionHandlerState();
}

class _TransactionHandlerState extends State<TransactionHandler> {
  late final SegmentedControlController _segmentedType;

  @override
  void initState() {
    super.initState();
    _segmentedType = SegmentedControlController();
    _segmentedType.setSelectedIndex(widget.initialType.index);
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
    final transactionFriends = widget.friends.toList(growable: false);
    final title = switch (selectedIndex) {
      0 => context.l10n.transactionExpenseTitle,
      1 => context.l10n.transactionIncomeTitle,
      _ => "",
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleAnimatedSwitcher(
          child: Text(
            title,
            key: ValueKey(selectedIndex),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        AppDimens.spacerMedium,
        if (widget.showTypeSelector) ...[
          SegmentedControlWidget(controller: _segmentedType),
          AppDimens.spacerMedium,
        ],
        Flexible(
          fit: FlexFit.loose,
          child: SmoothSwitcher(
            child: SingleChildScrollView(
              child: switch (selectedIndex) {
                0 => ExpenseForm(
                  user: widget.user,
                  friends: transactionFriends,
                ),
                1 => IncomeForm(user: widget.user, friends: transactionFriends),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ],
    );
  }
}
