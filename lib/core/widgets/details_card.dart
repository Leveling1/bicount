import 'package:flutter/material.dart';

import '../themes/app_dimens.dart';

class DetailsCard extends StatelessWidget {
  final Widget child;
  final bool isMargin;
  const DetailsCard({super.key, required this.child, this.isMargin = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: isMargin ? EdgeInsets.only(top: AppDimens.marginMedium) : null,
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
