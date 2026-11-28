import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class TitleIconButtomRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onPressed;
  const TitleIconButtomRow({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).cardColor,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: Theme.of(context).colorScheme.surfaceContainer,
              customBorder: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimens.paddingSmall,
                ), // 👈 espace cliquable
                child: Icon(
                  icon,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  size: AppSizes.dp20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
