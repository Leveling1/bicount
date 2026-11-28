import 'package:flutter/material.dart';

import 'app_sizes.dart';

export 'app_sizes.dart';

class AppDimens {
  // Border radius
  static const double borderRadiusNone = AppSizes.dp0;
  static const double borderRadiusExtraSmall = AppSizes.dp4;
  static const double borderRadiusSmall = AppSizes.dp8;
  static const double borderRadiusMedium = AppSizes.dp12;
  static const double borderRadiusMediumLarge = AppSizes.dp15;
  static const double borderRadiusLarge = AppSizes.dp20;
  static const double borderRadiusExtraLarge = AppSizes.dp28;
  static const double borderRadiusUltraLarge = AppSizes.dp50;
  static const double borderRadiusFull = AppSizes.dp100;

  // Padding
  static const double paddingExtraSmall = AppSizes.dp4;
  static const double paddingSmall = AppSizes.dp8;
  static const double paddingSmallMedium = AppSizes.dp12;
  static const double paddingMedium = AppSizes.dp16;
  static const double paddingLarge = AppSizes.dp24;
  static const double paddingExtraLarge = AppSizes.dp32;

  // Margin
  static const double marginExtraSmall = AppSizes.dp4;
  static const double marginSmall = AppSizes.dp8;
  static const double marginMedium = AppSizes.dp16;
  static const double marginLarge = AppSizes.dp24;

  // Spacing
  static const double spacingExtraSmall = AppSizes.dp4;
  static const double spacingSmall = AppSizes.dp8;
  static const double spacingMedium = AppSizes.dp16;
  static const double spacingLarge = AppSizes.dp24;
  static const double spacingExtraLarge = AppSizes.dp32;

  // Text size
  static const double textSizeExtraSmall = AppSizes.dp10;
  static const double textSizeSmall = AppSizes.dp12;
  static const double textSizeMedium = AppSizes.dp14;
  static const double textSizeLarge = AppSizes.dp18;
  static const double textSizeExtraLarge = AppSizes.dp24;
  static const double textSizeXXLarge = AppSizes.dp32;

  // Line-height multipliers
  static const double dialogBodyLineHeight = 1.45;
  static const double calendarHeaderLineHeight = 1.2;

  // Elevation
  static const double elevationLow = AppSizes.dp2;
  static const double elevationHigh = AppSizes.dp8;

  // Thickness
  static const double thicknessThin = AppSizes.dp1;

  // Letter spacing
  static const double letterSpacingTight = AppSizes.dp0Point6;

  // Sheet layout
  static const double sheetHorizontalPadding = AppSizes.dp25;
  static const double sheetHandleHeight = AppSizes.dp5;
  static const double sheetHandleGap = AppSizes.dp25;
  static const double sheetHeightFraction = 0.95;

  // Heights
  static const double bottomBarHeight = AppSizes.dp80;
  static const double appBarHeight = AppSizes.dp70;
  static const double appBarTabletHeight = AppSizes.dp200;
  static const double toolBarHeight = AppSizes.dp100;
  static const double toolBarTabletHeight = AppSizes.dp120;
  static const double tabBarHeight = AppSizes.dp40;
  static const double tabBarHeightAboutCompany = AppSizes.dp42;
  static const double logoWidth = AppSizes.dp122;
  static const double employeesStatisticContainerHeight = AppSizes.dp156;
  static const double modalDetailRecruiterHeight = AppSizes.dp200;
  static const double modalLastNotificationsHeight = AppSizes.dp350;
  static const double modalDetailDiscountHeight = AppSizes.dp350;
  static const double marketStatisticsChartHeight = AppSizes.dp380;
  static const double videosMaxHeight = AppSizes.dp400;
  static const double settingsAvatarPickerHeight = AppSizes.dp312;
  static const double settingsAvatarPreviewRadius = AppSizes.dp34;
  static const double settingsAvatarTileRadius = AppSizes.dp22;
  static const double settingsAvatarTileSize = AppSizes.dp64;
  static const double skeletonTileHeight = AppSizes.dp14;

  // Transaction rows
  static const double transactionAvatarRadius = AppSizes.dp20;
  static const double transactionAvatarSize = transactionAvatarRadius * 2;

  // Aspect ratios
  static const double aspectRatioWide = 18 / 9;
  static const double extentRatioNarrow = 0.34;

  // Max lines
  static const int maxLinesShort = 2;
  static const int maxLinesMedium = 4;
  static const int maxLinesLong = 6;
  static const int maxLinesExtraLong = 10;

  // Scroll
  static const double scrollStartPosition = AppSizes.dp0;

  // Radius (for shapes)
  static const double radiusNone = AppSizes.dp0;
  static const double radiusSmall = AppSizes.dp5;
  static const double radiusMedium = AppSizes.dp10;
  static const double radiusLarge = AppSizes.dp15;
  static const double radiusExtraLarge = AppSizes.dp25;
  static const double radiusXXLarge = AppSizes.dp30;

  // *** PADDING *** //

  // All
  static const paddingAllSmall = EdgeInsets.all(paddingSmall);
  static const paddingAllMedium = EdgeInsets.all(paddingMedium);
  static const paddingAllExtraLarge = EdgeInsets.all(paddingExtraLarge);

  // Symmetric
  static const paddingVerticalLargeHorizontalExtraLarge = EdgeInsets.symmetric(
    vertical: AppSizes.dp20,
    horizontal: AppSizes.dp32,
  );
  static const paddingSmallCard = EdgeInsets.symmetric(
    vertical: AppSizes.dp12,
    horizontal: AppSizes.dp8,
  );

  // Only
  static const paddingTopExtraSmallBottomSmall = EdgeInsets.only(
    top: AppSizes.dp4,
    bottom: AppSizes.dp10,
  );
  static const paddingTopXXLarge = EdgeInsets.only(top: AppSizes.dp30);
  static const paddingTopLarge = EdgeInsets.only(top: AppSizes.dp20);
  static const paddingTopMedium = EdgeInsets.only(top: AppSizes.dp16);

  // *** RADIUS *** //

  // Circular
  static final borderRadiusAllMedium = BorderRadius.circular(AppSizes.dp12);

  // Vertical
  static final borderRadiusTopExtraLarge = BorderRadius.vertical(
    top: Radius.circular(AppSizes.dp25),
  );

  // App padding
  static final appPadding = EdgeInsets.symmetric(horizontal: paddingMedium);

  // Icon Sizes
  static const double iconSizeExtraSmall = AppSizes.dp10;
  static const double iconSizeSmall = AppSizes.dp16;
  static const double iconSizeMedium = AppSizes.dp24;
  static const double iconSizeLarge = AppSizes.dp32;

  // *** SPACER *** //
  // Spacer Height
  static const spacerUltraSmall = SizedBox(height: AppSizes.dp2);
  static const spacerMini = SizedBox(height: AppSizes.dp5);
  static const spacerSmall = SizedBox(height: AppSizes.dp8);
  static const spacerMediumSmall = SizedBox(height: AppSizes.dp12);
  static const spacerMediumSmallLarge = SizedBox(height: AppSizes.dp15);
  static const spacerMedium = SizedBox(height: AppSizes.dp16);
  static const spacerMediumLarge = SizedBox(height: AppSizes.dp20);
  static const spacerLarge = SizedBox(height: AppSizes.dp24);
  static const spacerExtraLarge = SizedBox(height: AppSizes.dp32);
  static const spacerXXLarge = SizedBox(height: AppSizes.dp40);
  static const spacerXXXLarge = SizedBox(height: AppSizes.dp48);
  static const spacerXXXXLarge = SizedBox(height: AppSizes.dp56);
  static const spacerExtraXXXLarge = SizedBox(height: AppSizes.dp64);
  static const spacerExtraXXXXLarge = SizedBox(height: AppSizes.dp72);
  static const endSpacerHeight = SizedBox(height: AppSizes.dp110);

  // Spacer width
  static const spacerWidthMini = SizedBox(width: AppSizes.dp5);
  static const spacerWidthSmall = SizedBox(width: AppSizes.dp8);
  static const spacerWidthMediumSmall = SizedBox(width: AppSizes.dp12);
  static const spacerWidthMedium = SizedBox(width: AppSizes.dp16);
  static const spacerWidthLarge = SizedBox(width: AppSizes.dp24);
  static const spacerWidthExtraLarge = SizedBox(width: AppSizes.dp32);
  static const spacerWidthXXLarge = SizedBox(width: AppSizes.dp40);
  static const spacerWidthXXXLarge = SizedBox(width: AppSizes.dp48);
  static const spacerWidthXXXXLarge = SizedBox(width: AppSizes.dp56);
  static const spacerWidthExtraXXXLarge = SizedBox(width: AppSizes.dp64);
}
