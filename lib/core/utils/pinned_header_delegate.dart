import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const PinnedHeaderDelegate({required this.child});

  static const _height = 56.0; // ajuste selon ton widget

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant PinnedHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}