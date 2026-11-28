import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

import '../../../../core/themes/app_dimens.dart';

Widget _spacerHeight() => const SizedBox(height: AppDimens.marginMedium);
Widget _spacerWidth() => const SizedBox(width: AppDimens.marginMedium);

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar circulaire
        SkeletonItem(
          child: CircleAvatar(
            radius: AppSizes.dp50,
            backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
          ),
        ),

        _spacerHeight(),

        // Nom de l’entreprise
        SkeletonItem(
          child: Container(
            width: AppSizes.dp180,
            height: AppSizes.dp28,
            decoration: ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusSmall,
                ),
              ),
              color: Theme.of(context).cardColor.withValues(alpha: 0.3),
            ),
          ),
        ),

        _spacerHeight(),

        // Description
        SkeletonItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppSizes.dp220,
                height: AppSizes.dp14,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusSmall,
                    ),
                  ),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: AppSizes.dp6),
              Container(
                width: AppSizes.dp250,
                height: AppSizes.dp14,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusSmall,
                    ),
                  ),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: AppSizes.dp6),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: AppSizes.dp14,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusSmall,
                    ),
                  ),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),

        _spacerHeight(),

        // Pie chart (cercle simulé)
        SkeletonItem(
          child: CircleAvatar(
            radius: AppSizes.dp100,
            backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
          ),
        ),

        _spacerHeight(),

        // Ligne 1 : Profit / Salary
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: AppSizes.dp100,
                  decoration: ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(AppSizes.dp16),
                    ),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: AppSizes.dp100,
                  decoration: ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(AppSizes.dp16),
                    ),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),

        _spacerHeight(),

        // Ligne 2 : Equipment / Service
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: AppSizes.dp100,
                  decoration: ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(AppSizes.dp16),
                    ),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: AppSizes.dp100,
                  decoration: ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(AppSizes.dp16),
                    ),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GroupCardSkeleton extends StatelessWidget {
  const GroupCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const radius = AppSizes.dp50;

    return SizedBox(
      width: AppSizes.dp120,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.dp5),
        child: Column(
          children: [
            // Cercle image
            SkeletonItem(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(
                  context,
                ).cardColor.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            // Nom du groupe
            SkeletonItem(
              child: Container(
                width: AppSizes.dp80,
                height: AppSizes.dp12,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(AppSizes.dp6),
                  ),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.dp6),
            // Nombre de membres
            SkeletonItem(
              child: Container(
                width: AppSizes.dp60,
                height: AppSizes.dp10,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(AppSizes.dp6),
                  ),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
