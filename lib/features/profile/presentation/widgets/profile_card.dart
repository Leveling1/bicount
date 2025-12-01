import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      child: InkWell(
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusExtraLarge),
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  radius: 40,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(email, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
