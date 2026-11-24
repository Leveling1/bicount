import 'dart:math' as math;

import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:flutter/material.dart';

part 'wallet_card_stack_motion.dart';

class WalletCardStack extends StatefulWidget {
  const WalletCardStack({
    super.key,
    required this.wallets,
    required this.selectedIndex,
    required this.onChanged,
    this.balanceBuilder,
    this.loop = false,
  });

  final List<WalletModel?> wallets;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Widget Function(WalletModel?)? balanceBuilder;
  final bool loop;

  @override
  State<WalletCardStack> createState() => _WalletCardStackState();
}

class _WalletCardStackState extends State<WalletCardStack> {
  static const _depth = 8.0;
  int get _count => widget.wallets.length;
  bool get _loops => widget.loop && _count > 1;
  int get _pageCount => _loops ? _count * 3 : _count;
  int get _initialPage => widget.selectedIndex + (_loops ? _count : 0);
  int _walletIndex(int page) => page % _count;

  late final _pages = PageController(
    initialPage: _initialPage,
    keepPage: false,
  );
  late int _restingPage = _initialPage;

  @override
  void didUpdateWidget(WalletCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) return;
      final page = _pages.page ?? _restingPage.toDouble();
      final current = page.round();
      var delta = widget.selectedIndex - _walletIndex(current);
      if (_loops && delta.abs() > _count / 2) {
        delta += delta.isNegative ? _count : -_count;
      }
      final target = (current + delta).clamp(0, _pageCount - 1);
      if ((page - target).abs() < .001) return;
      if (MediaQuery.disableAnimationsOf(context) ||
          (page - target).abs() > 1) {
        _pages.jumpToPage(target);
      } else {
        _pages.animateToPage(
          target,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  bool _onScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0) return false;
    final page = _pages.page?.round();
    if (page == null || page == _restingPage) return false;
    final index = _walletIndex(page);
    setState(() => _restingPage = page);
    if (index != widget.selectedIndex) widget.onChanged(index);
    if (_loops && (page < _count || page >= _count * 2)) {
      // Move back to the middle copy while keeping the same wallet visible.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !_pages.hasClients ||
            _pages.position.isScrollingNotifier.value ||
            _pages.page?.round() != page) {
          return;
        }
        setState(() => _restingPage = _count + index);
        _pages.jumpToPage(_restingPage);
      });
    }
    return false;
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
          MediaQuery.sizeOf(context).height * .30 * WalletCardFace.aspectRatio,
        );
        final width = math.min(constraints.maxWidth, maxWidth);
        final height = width / WalletCardFace.aspectRatio;
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
                      ? _pages.page ?? _restingPage.toDouble()
                      : _restingPage.toDouble();
                  return _buildCards(
                    page,
                    width,
                    height,
                    layers,
                    direction,
                    reduceMotion,
                  );
                },
              ),
              NotificationListener<ScrollEndNotification>(
                onNotification: _onScrollEnd,
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _pageCount,
                  itemBuilder: (_, _) => const SizedBox.expand(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
