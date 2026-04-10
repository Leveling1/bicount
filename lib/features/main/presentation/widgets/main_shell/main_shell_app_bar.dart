import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  });

  final int connectionState;
  final String title;
  final int selectedIndex;
  final bool showSearchBar;
  final VoidCallback onToggleSearch;
  final VoidCallback onAddFunds;
  final VoidCallback onOpenSettings;

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
            2 => IconButton(
              key: ValueKey('search_$selectedIndex$showSearchBar'),
              onPressed: onToggleSearch,
              icon: Icon(
                showSearchBar ? Icons.close : Icons.search,
                key: ValueKey(showSearchBar ? 'icon_close' : 'icon_search'),
                color: Theme.of(context).textTheme.titleSmall!.color!,
                size: AppDimens.iconSizeMedium,
              ),
            ),
            3 => Row(
              key: ValueKey('profile_actions_$selectedIndex'),
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onOpenSettings,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                    size: AppDimens.iconSizeMedium,
                  ),
                ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 15, bottom: 15),
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.hexagonDots(
              color: Theme.of(context).colorScheme.error,
              size: 11,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.shellOfflineBadge,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
