import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bicount_skeleton.dart';

class AppAvatar extends StatelessWidget {
  final String? image;
  final double radius;
  final IconData fallbackIcon;

  const AppAvatar({
    super.key,
    required this.image,
    this.radius = 20,
    this.fallbackIcon = Icons.person_rounded,
  });

  bool get _isAssetImage => (image ?? '').startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final avatarColor = Theme.of(context).cardColor;
    final imagePath = image ?? '';
    final size = radius * 1.4;

    return CircleAvatar(
      backgroundColor: avatarColor,
      radius: radius,
      child: ClipOval(
        child: SizedBox(
          width: size.w,
          height: size.h,
          child: imagePath.isEmpty
              ? Icon(fallbackIcon, color: Theme.of(context).iconTheme.color)
              : _isAssetImage
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    fallbackIcon,
                    color: Theme.of(context).iconTheme.color,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => BicountSkeletonCircle(size: size),
                  errorWidget: (_, __, ___) => Icon(
                    fallbackIcon,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
        ),
      ),
    );
  }
}
