import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class CircleImageSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const CircleImageSkeleton({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: CircleAvatar(
        radius: width,
        backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
      ),
    );
  }
}
