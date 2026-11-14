import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const icons = [
      IconLinks.home,
      IconLinks.analysisIcon,
      IconLinks.transaction,
      IconLinks.user,
    ];
    final titles = [
      context.l10n.navHome,
      context.l10n.navAnalysis,
      context.l10n.navTransaction,
      context.l10n.navProfile,
    ];

    final theme = Theme.of(context);
    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor;
    final inactiveColor = AppColors.inactiveColorDark.withValues(alpha: 0.6);

    return Theme(
      data: theme.copyWith(splashColor: Colors.transparent),
      child: Container(
        //height: AppDimens.bottomBarHeight,
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
        child: ClipRRect(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: activeColor,
            unselectedItemColor: inactiveColor,
            selectedIconTheme: IconThemeData(color: activeColor, size: 24),
            unselectedIconTheme: IconThemeData(color: inactiveColor, size: 20),
            currentIndex: selectedIndex,
            onTap: onTap,
            items: List.generate(icons.length, (index) {
              return BottomNavigationBarItem(
                icon: Builder(
                  builder: (context) {
                    final iconTheme = IconTheme.of(context);
                    return SvgPicture.asset(
                      icons[index],
                      semanticsLabel: titles[index],
                      width: iconTheme.size,
                      height: iconTheme.size,
                      colorFilter: ColorFilter.mode(
                        iconTheme.color ?? inactiveColor,
                        BlendMode.srcIn,
                      ),
                    );
                  },
                ),
                label: titles[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}
