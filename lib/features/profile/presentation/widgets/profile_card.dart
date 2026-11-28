import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/core/utils/string_format_utils.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class ProfileCard extends StatelessWidget {
  final String image;
  final String name;
  final String email;
  final double? balance;
  final Function()? onTap;

  const ProfileCard({
    super.key,
    required this.image,
    required this.name,
    required this.email,
    this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BicountPressable(
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,
        customBorder: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusExtraLarge),
        ),
        onTap: onTap,
        child: Center(
          child: Column(
            children: [
              AppAvatar(image: image, radius: AppSizes.dp40),
              const SizedBox(height: AppSizes.dp12),
              Text(
                capitalizeFirstLetter(name),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimens.spacingExtraSmall),
              Text(email, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppDimens.spacingExtraSmall),
              Text(
                NumberFormatUtils.formatCurrency(balance ?? 0.0),
                style: (balance ?? 0.0) >= 0
                    ? Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
