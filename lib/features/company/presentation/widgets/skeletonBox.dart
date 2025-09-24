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
        const SkeletonAvatar(
          style: SkeletonAvatarStyle(
            shape: BoxShape.circle,
            width: 100,
            height: 100,
          ),
        ),

        _spacerHeight(),

        // Nom de l’entreprise
        SkeletonLine(
          style: SkeletonLineStyle(
            width: 180, // largeur fixe centrée
            height: 28,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        _spacerHeight(),

        // Description
        SkeletonItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // centrage
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(
                  width: 220, // largeur fixe
                  height: 14,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              SkeletonLine(
                style: SkeletonLineStyle(
                  width: 250, // largeur fixe
                  height: 14,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              SkeletonLine(
                style: SkeletonLineStyle(
                  width: MediaQuery.of(context).size.width * 0.6, // largeur contrôlée
                  height: 14,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),

        _spacerHeight(),

        // Pie chart (cercle simulé)
        const SkeletonAvatar(
          style: SkeletonAvatarStyle(
            shape: BoxShape.circle,
            width: 200,
            height: 200,
          ),
        ),

        _spacerHeight(),

        // Ligne 1 : Profit / Salary
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SkeletonItem(
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 100,
                    borderRadius: BorderRadius.circular(16),
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
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            _spacerWidth(),
            Expanded(
              child: SkeletonItem(
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 100,
                    borderRadius: BorderRadius.circular(16),
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
    final width = 120.0;
    final height = 120.0;
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
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
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
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
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
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

