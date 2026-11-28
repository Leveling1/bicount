part of 'bicount_pressable.dart';

extension _BicountPressableFeedback on _BicountPressableState {
  static const _pressDuration = Duration(milliseconds: 55);
  static const _releaseDuration = Duration(milliseconds: 140);

  Widget _buildFeedback(BuildContext context) {
    final legacy = WalletCorners.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final button = widget.builder;
    final tint = appPressedColor(Theme.of(context).primaryColor);
    final shape =
        widget.customBorder ??
        (widget.borderRadius == BorderRadius.zero
            ? appPressShape
            : appCornerShape(
                borderRadius: widget.borderRadius,
                legacy: legacy,
              ));
    final surface = button == null && !widget.isControl;
    final tintShape = shape is OutlinedBorder
        ? shape.copyWith(side: BorderSide.none)
        : shape;
    final animate = surface || !reduceMotion;
    final controller = animate ? _states : null;
    Widget buildSurface(Widget? child) => Material(
      type: widget.color == Colors.transparent
          ? MaterialType.transparency
          : MaterialType.canvas,
      color: widget.color,
      shape: shape,
      clipBehavior: widget.clipBehavior,
      child: InkWell(
        onTap: widget.onTap,
        onTapCancel: animate ? _cancelHold : null,
        statesController: controller,
        customBorder: shape,
        hoverColor: widget.hoverColor,
        splashFactory: !legacy ? NoSplash.splashFactory : null,
        overlayColor: !legacy
            ? const WidgetStateProperty.fromMap({
                WidgetState.pressed: Colors.transparent,
              })
            : null,
        child: child,
      ),
    );

    final contentOnly = surface && widget.scaleContentOnly;
    final paintTint = surface && !legacy;
    final content = widget.isControl || contentOnly
        ? widget.child
        : button?.call(controller) ?? buildSurface(widget.child);

    final feedback = ValueListenableBuilder(
      valueListenable: _showPress,
      child: content,
      builder: (context, pressed, child) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: pressed ? 1 : 0),
        duration: reduceMotion
            ? Duration.zero
            : pressed
            ? _pressDuration
            : _releaseDuration,
        curve: Curves.easeOutCubic,
        child:
            widget.controlBuilder?.call(context, widget.enabled && pressed) ??
            child,
        builder: (context, progress, child) {
          Widget scale(Widget? contents) => Transform.scale(
            scale: reduceMotion ? 1 : 1 - 0.03 * progress,
            transformHitTests: false,
            child: contents,
          );

          final tintDecoration = ShapeDecoration(
            color: tint.withValues(alpha: tint.a * progress),
            shape: tintShape,
          );

          if (contentOnly) {
            final contents = scale(child);
            return buildSurface(
              paintTint
                  ? DecoratedBox(decoration: tintDecoration, child: contents)
                  : contents,
            );
          }

          return scale(
            paintTint
                ? DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: tintDecoration,
                    child: child,
                  )
                : child,
          );
        },
      ),
    );
    if (!widget.isControl) return feedback;

    return _observePointer(feedback);
  }
}
