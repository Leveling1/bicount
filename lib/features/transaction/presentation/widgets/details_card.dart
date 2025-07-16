import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class DetailsCard extends StatelessWidget {
  final Widget child;
  const DetailsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppDimens.marginMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: child,
      ),
    );
  }
}
