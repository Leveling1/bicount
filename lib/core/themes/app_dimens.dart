import 'package:flutter/material.dart';

class AppDimens {
  // Border radius
  static const double borderRadiusNone = 0.0;
  static const double borderRadiusExtraSmall = 4.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusExtraLarge = 28.0;
  static const double borderRadiusUltraLarge = 50.0;
  static const double borderRadiusFull = 100.0;

  // Padding
  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Margin
  static const double marginExtraSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Text size
  static const double textSizeExtraSmall = 10.0;
  static const double textSizeSmall = 12.0;
  static const double textSizeMedium = 14.0;
  static const double textSizeLarge = 18.0;
  static const double textSizeExtraLarge = 24.0;
  static const double textSizeXXLarge = 32.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationHigh = 8.0;

  // Thickness
  static const double thicknessThin = 1.0;

  // Letter spacing
  static const double letterSpacingTight = 0.6;

  // Heights
  static const double bottomBarHeight = 88.0;
  static const double appBarHeight = 70.0;
  static const double appBarTabletHeight = 200.0;
  static const double toolBarHeight = 100.0;
  static const double toolBarTabletHeight = 120.0;
  static const double tabBarHeight = 40.0;
  static const double tabBarHeightAboutCompany = 42.0;
  static const double logoWidth = 122.0;
  static const double employeesStatisticContainerHeight = 156.0;
  static const double modalDetailRecruiterHeight = 200.0;
  static const double modalLastNotificationsHeight = 350.0;
  static const double modalDetailDiscountHeight = 350.0;
  static const double marketStatisticsChartHeight = 380.0;
  static const double videosMaxHeight = 400.0;

  // Aspect ratios
  static const double aspectRatioWide = 18 / 9;
  static const double extentRatioNarrow = 0.34;

  // Max lines
  static const int maxLinesShort = 2;
  static const int maxLinesMedium = 4;
  static const int maxLinesLong = 6;
  static const int maxLinesExtraLong = 10;

  // Scroll
  static const double scrollStartPosition = 0.0;

  // Radius (for shapes)
  static const double radiusNone = 0.0;
  static const double radiusSmall = 5.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 25.0;
  static const double radiusXXLarge = 30.0;

  // *** PADDING *** //

  // All
  static const paddingAllSmall = EdgeInsets.all(8);
  static const paddingAllMedium = EdgeInsets.all(16);
  static const paddingAllExtraLarge = EdgeInsets.all(32);

  // Symmetric
  static const paddingVerticalLargeHorizontalExtraLarge = EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 32,
  );
  static const paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: 16);

  // Only
  static const paddingTopExtraSmallBottomSmall = EdgeInsets.only(
    top: 4,
    bottom: 10,
  );
  static const paddingTopXXLarge = EdgeInsets.only(top: 30);
  static const paddingTopLarge = EdgeInsets.only(top: 20);
  static const paddingTopMedium = EdgeInsets.only(top: 16);

  // *** RADIUS *** //

  // Circular
  static final borderRadiusAllMedium = BorderRadius.circular(12);

  // Vertical
  static final borderRadiusTopExtraLarge = BorderRadius.vertical(
    top: Radius.circular(25),
  );
}
