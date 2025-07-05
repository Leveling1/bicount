import 'package:flutter/material.dart';
import 'package:bicount/core/themes/app_dimens.dart';

class ContainerBody extends StatelessWidget {
  final Widget child;
  const ContainerBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.marginMedium),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimens.borderRadiusUltraLarge),
            bottomRight: Radius.circular(AppDimens.borderRadiusUltraLarge),
          ),
        ),
        child: child,
      ),
    );
  }
}
