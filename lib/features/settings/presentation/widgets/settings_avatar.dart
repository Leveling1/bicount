import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

class SettingsAvatar extends StatelessWidget {
  const SettingsAvatar({super.key, required this.image, this.radius = 26});

  final String image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolvedImage = image.isEmpty ? Constants.memojiDefault : image;
    return AppAvatar(image: resolvedImage, radius: radius);
  }
}
