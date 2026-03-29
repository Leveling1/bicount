import 'package:flutter/material.dart';

import 'bicount_skeleton.dart';

class CircleImageSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const CircleImageSkeleton({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return BicountSkeletonCircle(size: width * 2, margin: EdgeInsets.zero);
  }
}
