import 'package:flutter/material.dart';
import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';

class ContainerBody extends StatelessWidget {
  final Widget child;
  const ContainerBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.marginExtraSmall),
      padding: EdgeInsets.only(left: AppDimens.paddingLarge, right: AppDimens.paddingLarge, bottom: AppDimens.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.cardColorDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.dorderRadiusUltraLarge),
          bottomRight: Radius.circular(AppDimens.dorderRadiusUltraLarge),
        ),
      ),
      child: child,
    );
  }
}
