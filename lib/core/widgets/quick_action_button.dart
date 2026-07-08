import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_handler.dart';
import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isLeft = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor, // theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        hoverColor: theme.colorScheme.surfaceContainer,
        splashColor: Colors.transparent,
        highlightColor: theme.primaryColor.withValues(alpha: 0.16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingMedium,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLeft) ...[
                _buildText(context),
                const SizedBox(width: AppDimens.spacingSmall),
              ],
              Container(
                width: AppDimens.iconSizeLarge,
                height: AppDimens.iconSizeLarge,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: AppDimens.iconSizeSmall,
                ),
              ),
              if (!isLeft) ...[
                const SizedBox(width: AppDimens.spacingSmall),
                _buildText(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class TransactionButton extends StatelessWidget {
  const TransactionButton({
    super.key,
    required this.data,
    this.prefilledFriend,
  });
  final MainEntity data;
  final FriendsModel? prefilledFriend;

  @override
  Widget build(BuildContext context) {
    final incomeColor = Theme.of(context).extension<OtherTheme>()!.income!;
    final expenseColor = Theme.of(context).extension<OtherTheme>()!.expense!;
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            isLeft: true,
            icon: Icons.arrow_upward_rounded,
            label: context.l10n.homeQuickExpense,
            color: expenseColor,
            onTap: () => openTransactionSheet(
              context,
              data,
              initialType: TransactionHandlerInitialType.expense,
              showTypeSelector: false,
              prefilledFriend: prefilledFriend,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.marginMedium),
        Expanded(
          child: QuickActionButton(
            icon: Icons.arrow_downward_rounded,
            label: context.l10n.homeQuickIncome,
            color: incomeColor,
            onTap: () => openTransactionSheet(
              context,
              data,
              initialType: TransactionHandlerInitialType.income,
              showTypeSelector: false,
              prefilledFriend: prefilledFriend,
            ),
          ),
        ),
      ],
    );
  }
}
