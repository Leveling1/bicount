import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      IconLinks.graphIcon,
      IconLinks.transaction,
      IconLinks.user,
    ];
    final titles = [
      context.l10n.navHome,
      context.l10n.navGraphs,
      context.l10n.navTransaction,
      context.l10n.navProfile,
    ];

    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: Container(
        //height: AppDimens.bottomBarHeight.h,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
        child: ClipRRect(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryColorDark,
            unselectedItemColor: AppColors.inactiveColorDark,
            currentIndex: selectedIndex,
            onTap: onTap,
            items: List.generate(icons.length, (index) {
              final size = selectedIndex == index ? 24.0 : 20.0;
              return BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  icons[index],
                  semanticsLabel: titles[index],
                  width: size,
                  height: size,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == index
                        ? AppColors.secondaryColorBasic
                        : AppColors.inactiveColorDark,
                    BlendMode.srcIn,
                  ),
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
