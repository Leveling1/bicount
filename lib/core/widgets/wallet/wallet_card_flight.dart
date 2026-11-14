import 'package:flutter/material.dart';

enum WalletCardEndpoint { preview, list }

class WalletCardFlight extends InheritedWidget {
  const WalletCardFlight({
    super.key,
    required this.geometry,
    required this.movingIds,
    required super.child,
  });

  final WalletCardFlightGeometry geometry;
  final Set<String> movingIds;

  static WalletCardFlight? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WalletCardFlight>();

  @override
  bool updateShouldNotify(WalletCardFlight oldWidget) =>
      movingIds != oldWidget.movingIds || geometry != oldWidget.geometry;
}

class WalletCardFlightGeometry {
  final previewPage = GlobalKey();
  final listPage = GlobalKey();
  final _anchors = <(WalletCardEndpoint, String), GlobalKey>{};

  GlobalKey anchor(WalletCardEndpoint endpoint, String walletId) =>
      _anchors.putIfAbsent((endpoint, walletId), GlobalKey.new);

  Rect? bounds(WalletCardEndpoint endpoint, String walletId) {
    final page = endpoint == WalletCardEndpoint.preview
        ? previewPage
        : listPage;
    final ancestor = page.currentContext?.findRenderObject();
    final box = _anchors[(endpoint, walletId)]?.currentContext
        ?.findRenderObject();
    if (box is! RenderBox ||
        !box.attached ||
        !box.hasSize ||
        ancestor is! RenderBox ||
        !ancestor.attached) {
      return null;
    }
    return MatrixUtils.transformRect(
      box.getTransformTo(ancestor),
      Offset.zero & box.size,
    );
  }
}
