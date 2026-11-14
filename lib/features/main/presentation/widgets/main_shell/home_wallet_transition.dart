import 'dart:math' as math;

import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_flight.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_cards.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_wallet_scene.dart';

class HomeWalletTransition extends StatefulWidget {
  const HomeWalletTransition({
    super.key,
    required this.enabled,
    required this.hasSharedContainer,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.builder,
  });

  final bool enabled;
  final bool hasSharedContainer;
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;
  final Widget Function(VoidCallback openWallets) builder;

  @override
  State<HomeWalletTransition> createState() => _HomeWalletTransitionState();
}

class _HomeWalletTransitionState extends State<HomeWalletTransition>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(vsync: this);
  final _geometry = WalletCardFlightGeometry();
  List<HomeWalletCardPath> _paths = [];
  Set<String> _movingIds = const {};
  bool _showWallet = false;
  bool _open = false;
  bool _dragging = false;
  bool _ready = false;
  bool _measuring = false;
  double _position = 0;
  int? _nextTab;

  @override
  void didUpdateWidget(HomeWalletTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled && _showWallet) {
      _animation.stop();
      _animation.value = 0;
      _paths = [];
      _movingIds = const {};
      _showWallet = _open = _dragging = _ready = _measuring = false;
      _nextTab = null;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _prepare({required bool dragging}) {
    _animation.stop();
    _position = _animation.value;
    if (_ready || _measuring) {
      _dragging = dragging;
      return;
    }
    setState(() {
      _dragging = dragging;
      _showWallet = true;
      _measuring = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showWallet) return;
      _paths = _measurePaths();
      setState(() {
        _movingIds = _paths.map((path) => path.wallet.id).toSet();
        _measuring = false;
        _ready = true;
        _animation.value = _position;
      });
      if (!_dragging) _settle();
    });
  }

  void _go(bool open) {
    _open = open;
    _dragging = false;
    if (_ready) {
      _settle();
    } else if (!_measuring) {
      _prepare(dragging: false);
    }
  }

  Future<void> _settle() async {
    final destination = _open ? 1.0 : 0.0;
    final atDestination = _animation.value == destination;
    try {
      if (!atDestination) {
        await _animation
            .animateTo(
              destination,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : Duration(
                      milliseconds: math.max(
                        130,
                        (390 * (destination - _animation.value).abs()).round(),
                      ),
                    ),
              curve: Curves.easeOutCubic,
            )
            .orCancel;
      }
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWallet = _open;
      _movingIds = const {};
      _paths = [];
      _ready = false;
    });
    final tab = _nextTab;
    _nextTab = null;
    if (tab != null && !_open) widget.onSelectTab(tab);
  }

  void _selectTab(int tab) {
    if (!_showWallet) {
      widget.onSelectTab(tab);
    } else {
      _nextTab = tab;
      _go(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forward = Directionality.of(context) == TextDirection.ltr ? -1 : 1;
    final enabled = widget.enabled;
    final moving =
        _showWallet && (_measuring || _ready || _animation.value != 1);
    return WalletCardFlight(
      geometry: _geometry,
      movingIds: _movingIds,
      child: PopScope(
        canPop: !_showWallet,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _showWallet) _go(false);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: enabled
                  ? (_) => _prepare(dragging: true)
                  : null,
              onHorizontalDragUpdate: enabled
                  ? (event) {
                      if (!_dragging) return;
                      _position = (_position + event.delta.dx * forward / width)
                          .clamp(0.0, 1.0);
                      if (_ready) _animation.value = _position;
                    }
                  : null,
              onHorizontalDragEnd: enabled
                  ? (event) {
                      if (!_dragging) return;
                      final velocity = (event.primaryVelocity ?? 0) * forward;
                      _go(
                        velocity > 500 ||
                            (velocity >= -500 &&
                                _position > (_open ? .68 : .32)),
                      );
                    }
                  : null,
              onHorizontalDragCancel: enabled
                  ? () {
                      if (_dragging) _go(_open);
                    }
                  : null,
              child: _scene(moving, forward),
            );
          },
        ),
      ),
    );
  }
}
