import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class CompanyImageSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const CompanyImageSkeleton({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: SkeletonAvatar(
        style: SkeletonAvatarStyle(
          width: width,
          height: height,
          borderRadius: BorderRadius.circular(width / 2), // cercle
        ),
      ),
    );
  }
}
