import 'package:flutter/material.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    List<IconData> icons = const [Icons.home, Icons.data_array];
    List<String> titles = const ['Home', 'Company'];

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        //highlightColor: Colors.transparent,
      ),
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
              return BottomNavigationBarItem(
                icon: Icon(icons[index], size: 24),
                label: titles[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}
