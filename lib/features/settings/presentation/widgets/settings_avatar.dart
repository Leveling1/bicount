import 'package:bicount/core/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SettingsAvatar extends StatelessWidget {
  const SettingsAvatar({super.key, required this.image, this.radius = 26});

  final String image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolvedImage = image.isEmpty ? Constants.memojiDefault : image;
    final size = radius * 1.25;
    final isNetworkImage = resolvedImage.startsWith('http');

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).cardColor,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: isNetworkImage
              ? CachedNetworkImage(imageUrl: resolvedImage, fit: BoxFit.cover)
              : Image.asset(resolvedImage, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
