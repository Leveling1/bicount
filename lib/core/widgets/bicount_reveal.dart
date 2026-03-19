import 'dart:async';

import 'package:flutter/material.dart';

class BicountReveal extends StatefulWidget {
  const BicountReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 280),
    this.beginOffset = const Offset(0, 0.06),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;
  final bool enabled;

  @override
  State<BicountReveal> createState() => _BicountRevealState();
}

class _BicountRevealState extends State<BicountReveal> {
  Timer? _timer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _isVisible = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.delay == Duration.zero) {
        setState(() => _isVisible = true);
        return;
      }

      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() => _isVisible = true);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedOpacity(
      duration: widget.duration,
      curve: widget.curve,
      opacity: _isVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: widget.curve,
        offset: _isVisible ? Offset.zero : widget.beginOffset,
        child: widget.child,
      ),
    );
  }
}
