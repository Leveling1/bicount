import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Measures both header states at the available width before laying out the sliver.
class HomeHeaderSliverLayout extends MultiChildRenderObjectWidget {
  HomeHeaderSliverLayout({
    super.key,
    required Widget expanded,
    required Widget collapsed,
    required this.backgroundColor,
  }) : super(children: [expanded, collapsed]);

  final Color backgroundColor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHomeHeaderSliver(backgroundColor);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliver renderObject,
  ) {
    (renderObject as _RenderHomeHeaderSliver).backgroundColor = backgroundColor;
  }
}

class _HomeHeaderParentData extends SliverPhysicalParentData
    with ContainerParentDataMixin<RenderBox> {}

class _RenderHomeHeaderSliver extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderBox, _HomeHeaderParentData>,
        RenderSliverHelpers {
  _RenderHomeHeaderSliver(this._backgroundColor);

  Color _backgroundColor;
  double _fade = 0;
  final _expandedLayer = LayerHandle<OpacityLayer>();
  final _collapsedLayer = LayerHandle<OpacityLayer>();
  final _clipLayer = LayerHandle<ClipRectLayer>();

  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _HomeHeaderParentData) {
      child.parentData = _HomeHeaderParentData();
    }
  }

  @override
  void performLayout() {
    final boxConstraints = constraints.asBoxConstraints();
    firstChild!.layout(boxConstraints, parentUsesSize: true);
    lastChild!.layout(boxConstraints, parentUsesSize: true);
    final expandedHeight = firstChild!.size.height;
    final collapsedHeight = math.min(expandedHeight, lastChild!.size.height);
    final distance = expandedHeight - collapsedHeight;
    _fade = distance <= 0
        ? 1
        : Curves.easeInOut.transform(
            (constraints.scrollOffset / (distance * .58)).clamp(0.0, 1.0),
          );

    final availablePaint = math.max(
      0.0,
      constraints.remainingPaintExtent - constraints.overlap,
    );
    final layoutExtent = (expandedHeight - constraints.scrollOffset).clamp(
      0.0,
      availablePaint,
    );
    final visibleHeight = math.max(
      collapsedHeight,
      expandedHeight - constraints.scrollOffset,
    );
    geometry = SliverGeometry(
      scrollExtent: expandedHeight,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(visibleHeight, availablePaint),
      layoutExtent: layoutExtent,
      maxPaintExtent: expandedHeight,
      maxScrollObstructionExtent: collapsedHeight,
      cacheExtent: layoutExtent > 0
          ? layoutExtent - constraints.cacheOrigin
          : 0,
      hasVisualOverflow: true,
    );
    (firstChild!.parentData! as _HomeHeaderParentData).paintOffset =
        Offset.zero;
    (lastChild!.parentData! as _HomeHeaderParentData).paintOffset = Offset.zero;
    markNeedsSemanticsUpdate();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry!.visible) return;
    final bounds = Rect.fromLTWH(
      0,
      0,
      constraints.crossAxisExtent,
      geometry!.paintExtent,
    );
    _clipLayer.layer = context.pushClipRect(needsCompositing, offset, bounds, (
      context,
      offset,
    ) {
      context.canvas.drawRect(
        bounds.shift(offset),
        Paint()..color = _backgroundColor,
      );
      final childOffset = offset + Offset.zero;
      _paintChild(context, childOffset, firstChild!, 1 - _fade, _expandedLayer);
      _paintChild(context, childOffset, lastChild!, _fade, _collapsedLayer);
    }, oldLayer: _clipLayer.layer);
  }

  void _paintChild(
    PaintingContext context,
    Offset offset,
    RenderBox child,
    double opacity,
    LayerHandle<OpacityLayer> layer,
  ) {
    if (opacity == 0) return;
    layer.layer = context.pushOpacity(
      offset,
      (opacity * 255).round(),
      (context, offset) => context.paintChild(child, offset),
      oldLayer: layer.layer,
    );
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) => hitTestBoxChild(
    BoxHitTestResult.wrap(result),
    _fade < .5 ? firstChild! : lastChild!,
    mainAxisPosition: mainAxisPosition,
    crossAxisPosition: crossAxisPosition,
  );

  @override
  double childMainAxisPosition(covariant RenderBox child) => 0;

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    (child.parentData! as _HomeHeaderParentData).applyPaintTransform(transform);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitor(_fade < .5 ? firstChild! : lastChild!);
  }

  @override
  void dispose() {
    _expandedLayer.layer = null;
    _collapsedLayer.layer = null;
    _clipLayer.layer = null;
    super.dispose();
  }
}
