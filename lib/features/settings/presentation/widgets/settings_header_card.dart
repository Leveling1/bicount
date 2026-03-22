import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_avatar.dart';
import 'package:flutter/material.dart';

class SettingsHeaderCard extends StatelessWidget {
  const SettingsHeaderCard({
    super.key,
    required this.user,
    required this.subtitle,
  });

  final UserModel user;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      isMargin : false,
      child: Row(
        children: [
          SettingsAvatar(image: user.image, radius: 28),
          AppDimens.spacerMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppDimens.spacerMini,
                Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                AppDimens.spacerSmall,
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
