import 'dart:math' as math;

import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_card_face.dart';
import 'package:flutter/material.dart';

class WalletCardStack extends StatefulWidget {
  const WalletCardStack({
    super.key,
    required this.wallets,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<WalletModel?> wallets;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<WalletCardStack> createState() => _WalletCardStackState();
}

class _WalletCardStackState extends State<WalletCardStack> {
  static const _depth = 8.0;
  late final _pages = PageController(
    initialPage: widget.selectedIndex,
    keepPage: false,
  );
  late int _restingIndex = widget.selectedIndex;

  @override
  void didUpdateWidget(WalletCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) return;
      final index = widget.selectedIndex;
      if (_pages.page?.round() == index) return;
      if (MediaQuery.disableAnimationsOf(context) ||
          ((_pages.page ?? index) - index).abs() > 1) {
        _pages.jumpToPage(index);
        setState(() => _restingIndex = index);
      } else {
        _pages.animateToPage(
          index,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = math.min(2, widget.wallets.length - 1);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.min(
          390.0,
          MediaQuery.sizeOf(context).height * .30 * 1.59,
        );
        final width = math.min(constraints.maxWidth, maxWidth);
        final height = width / 1.59;
        return SizedBox(
          width: width,
          height: height + layers * _depth,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _pages,
                builder: (context, _) {
                  final page =
                      _pages.hasClients && _pages.position.hasContentDimensions
                      ? _pages.page ?? widget.selectedIndex.toDouble()
                      : widget.selectedIndex.toDouble();
                  final lastIndex = widget.wallets.length - 1;
                  final current = _restingIndex.clamp(0, lastIndex);
                  final offset = (page - current).clamp(-1.0, 1.0);
                  final next = (current + offset.sign.toInt()).clamp(
                    0,
                    lastIndex,
                  );
                  final progress = offset.abs();
                  final rear = [
                    for (var step = 1; step < widget.wallets.length; step++)
                      (current + step) % widget.wallets.length,
                  ];
                  if (next != current) {
                    rear.remove(next);
                    rear.insert(0, next);
                  }

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      for (var layer = layers; layer >= 1; layer--)
                        Transform.translate(
                          offset: Offset(
                            0,
                            -_depth * (layer - (layer == 1 ? progress : 0)),
                          ),
                          child: Transform.scale(
                            scale:
                                1 -
                                .035 * (layer - (layer == 1 ? progress : 0)),
                            alignment: Alignment.topCenter,
                            child: _face(
                              rear[layer - 1],
                              height,
                              foreground: layer == 1 && progress > 0,
                            ),
                          ),
                        ),
                      if (progress < 1)
                        Transform.translate(
                          offset: Offset(-offset * width * direction, 0),
                          child: Transform.rotate(
                            angle: reduceMotion ? 0 : -offset * direction * .12,
                            child: Opacity(
                              opacity: ((1 - progress) / .2).clamp(0.0, 1.0),
                              child: _face(current, height, foreground: true),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  final index = _pages.page?.round();
                  if (index != null && index != _restingIndex) {
                    setState(() => _restingIndex = index);
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pages,
                  itemCount: widget.wallets.length,
                  onPageChanged: (index) {
                    if (index != widget.selectedIndex) widget.onChanged(index);
                  },
                  itemBuilder: (_, _) => const SizedBox.expand(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _face(int index, double height, {required bool foreground}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: WalletCardFace(
        wallet: widget.wallets[index],
        showDetails: foreground,
      ),
    );
  }
}
