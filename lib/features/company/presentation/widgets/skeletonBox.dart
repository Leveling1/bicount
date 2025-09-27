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
            radius: 50,
            backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
          ),
        ),

        _spacerHeight(),

        // Nom de l’entreprise
        SkeletonItem(
          child: Container(
            width: 180,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
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
                width: 220,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 250,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
            radius: 100,
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
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
    final radius = 50.0;

    return SizedBox(
      width: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            // Cercle image
            SkeletonItem(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 8),
            // Nom du groupe
            SkeletonItem(
              child: Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Nombre de membres
            SkeletonItem(
              child: Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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

