import 'package:flutter/material.dart';
import '../../../../core/widgets/user_card.dart';

class MembersSkeleton extends StatelessWidget {
  final int itemCount;

  const MembersSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Nombre de colonnes
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 3 / 3,
      ),
      itemBuilder: (context, index) {
        return UserCardSkeleton();
      },
    );
  }
}
