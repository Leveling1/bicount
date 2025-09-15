import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/themes/app_colors.dart';
import 'company_image_skeleton.dart';

class CompanyProfil extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String? image;
  const CompanyProfil({
    super.key,
    required this.width,
    required this.height,
    this.radius = 20,
    this.image
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      radius: radius,
      child: ClipOval(
        child: image != null && image != ""
        ? CachedNetworkImage(
          imageUrl: image!,
          width: width.w,
          height: height.h,
          placeholder: (context, url) => CompanyImageSkeleton(
            width: width.w,
            height: height.h
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
        ) : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            "assets/icons/company_card_icon.svg",
            semanticsLabel: "Company",
            width: width.w,
            height: height.h,
            colorFilter: ColorFilter.mode(
              AppColors.inactiveColorDark,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
