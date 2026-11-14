part of 'home_wallet_transition.dart';

class _HomeWalletScene extends StatelessWidget {
  const _HomeWalletScene({
    required this.animation,
    required this.forward,
    required this.moving,
    required this.ready,
    required this.showWallet,
    required this.direct,
    required this.paths,
    required this.geometry,
    required this.home,
  });

  final Animation<double> animation;
  final int forward;
  final bool moving;
  final bool ready;
  final bool showWallet;
  final bool direct;
  final List<HomeWalletCardPath> paths;
  final WalletCardFlightGeometry geometry;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    final walletActive = showWallet && !moving && !direct;
    final slide = CurveTween(curve: const Interval(0, .76));
    final wallet = showWallet
        ? SizedBox.expand(key: geometry.listPage, child: const WalletScreen())
        : null;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (wallet != null)
            ExcludeSemantics(
              excluding: !walletActive,
              child: IgnorePointer(
                ignoring: !walletActive,
                child: SlideTransition(
                  position:
                      Tween(
                            begin: Offset(
                              (direct ? forward : -forward).toDouble(),
                              0,
                            ),
                            end: Offset.zero,
                          )
                          .chain(
                            direct ? CurveTween(curve: Curves.linear) : slide,
                          )
                          .animate(animation),
                  child: wallet,
                ),
              ),
            ),
          SlideTransition(
            position:
                Tween(
                      begin: Offset.zero,
                      end: Offset((direct ? -forward : forward).toDouble(), 0),
                    )
                    .chain(direct ? CurveTween(curve: Curves.linear) : slide)
                    .animate(animation),
            child: ExcludeSemantics(
              excluding: showWallet,
              child: IgnorePointer(
                ignoring: showWallet,
                child: SizedBox.expand(key: geometry.previewPage, child: home),
              ),
            ),
          ),
          if (ready && paths.isNotEmpty)
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) =>
                  HomeWalletCards(paths: paths, progress: animation.value),
            ),
        ],
      ),
    );
  }
}

extension _HomeWalletSceneLayout on _HomeWalletTransitionState {
  Widget _scene(bool moving, int forward) {
    final scene = _HomeWalletScene(
      animation: _animation,
      forward: forward,
      moving: moving,
      ready: _ready,
      showWallet: _showWallet,
      direct: _directTab != null,
      paths: _paths,
      geometry: _geometry,
      home: widget.builder(() => _go(true)),
    );
    if (!widget.hasSharedContainer) return scene;
    final theme = Theme.of(context);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return ColoredBox(
      color:
          theme.bottomNavigationBarTheme.backgroundColor ??
          theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: ContainerBody(protectTopInset: false, child: scene),
            ),
          ),
          if (!keyboardVisible)
            CustomBottomNavigationBar(
              selectedIndex: widget.selectedIndex,
              onTap: _selectTab,
            ),
        ],
      ),
    );
  }

  Future<void> _selectTab(int tab) async {
    if (_directTab != null) return;
    if (!_showWallet) {
      widget.onSelectTab(tab);
      return;
    }
    if (tab == 0) {
      _go(false);
      return;
    }

    _updateScene(() {
      _directTab = tab;
      _animation.value = 1;
      _paths = [];
      _movingIds = const {};
      _dragging = _ready = _measuring = false;
    });
    widget.onSelectCoveredTab(tab);
    try {
      await _animation
          .animateTo(
            0,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
          )
          .orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    _updateScene(() {
      _directTab = null;
      _showWallet = _open = false;
    });
  }

  List<HomeWalletCardPath> _measurePaths() {
    final wallets = context.read<WalletBloc>().state.wallets;
    return [
      for (final wallet
          in wallets.where((wallet) => wallet.archivedAt == null).take(3))
        if (_geometry.bounds(WalletCardEndpoint.preview, wallet.id)
            case final Rect preview)
          if (_geometry.bounds(WalletCardEndpoint.list, wallet.id)
              case final Rect destination)
            HomeWalletCardPath(wallet, preview, destination),
    ];
  }
}
