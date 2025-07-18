import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> icons = const [
      'assets/icons/home.svg',
      'assets/icons/company.svg',
      'assets/icons/transaction.svg',
      'assets/icons/custom_user_iconcustom_user_icon.svg',
    ];
    List<String> titles = const ['Home', 'Company', 'Transaction', 'Profile'];

    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: Container(
        height: AppDimens.bottomBarHeight.h,
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
              double size = selectedIndex == index ? 24 : 20;
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
