import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/open_invite_hub.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_badge.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/presentation/widgets/transaction_option_button.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:flutter/material.dart';

class MainShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainShellAppBar({
    super.key,
    required this.connectionState,
    required this.title,
    required this.selectedIndex,
    required this.showSearchBar,
    required this.onToggleSearch,
    required this.onAddFunds,
    required this.onOpenSettings,
    required this.debts,
    required this.recurringTransferts,
  });

  final int connectionState;
  final String title;
  final int selectedIndex;
  final bool showSearchBar;
  final VoidCallback onToggleSearch;
  final VoidCallback onAddFunds;
  final VoidCallback onOpenSettings;
  final List<DebtModel> debts;
  final List<RecurringTransfertModel> recurringTransferts;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: connectionState == Constants.disconnected ? 110.0 : null,
      leading: connectionState == Constants.disconnected
          ? const _OfflineBadge()
          : null,
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: switch (selectedIndex) {
            2 => Row(
              key: ValueKey('search_$selectedIndex$showSearchBar'),
              mainAxisSize: MainAxisSize.min,
              children: [
                TransactionOptionButton(
                  debts: debts,
                  recurringTransferts: recurringTransferts,
                ),
                CustomIconButton(
                  onPressed: onToggleSearch,
                  icon: showSearchBar ? Icons.close : Icons.search,
                ),
                AppDimens.spacerWidthMedium,
              ],
            ),
            3 => Row(
              key: ValueKey('profile_actions_$selectedIndex'),
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconButton(
                  onPressed: () => openInviteHub(context),
                  icon: Icons.qr_code_2_outlined,
                ),
                CustomIconButton(
                  onPressed: onOpenSettings,
                  icon: Icons.settings,
                ),

                AppDimens.spacerWidthMedium,
              ],
            ),
            _ => const SizedBox.shrink(key: ValueKey('no_action')),
          },
        ),
      ],
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();
  @override
  Widget build(BuildContext context) {
    return CustomBadge(
      text: context.l10n.shellOfflineBadge,
      color: Theme.of(context).colorScheme.error,
    );
  }
}
