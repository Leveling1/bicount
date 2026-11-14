part of 'home_wallet_transition.dart';

class _HomeWalletScene extends StatelessWidget {
  const _HomeWalletScene({
    required this.animation,
    required this.forward,
    required this.moving,
    required this.ready,
    required this.showWallet,
    required this.paths,
    required this.geometry,
    required this.home,
  });

  final Animation<double> animation;
  final int forward;
  final bool moving;
  final bool ready;
  final bool showWallet;
  final List<HomeWalletCardPath> paths;
  final WalletCardFlightGeometry geometry;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    final walletActive = showWallet && !moving;
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
                            begin: Offset(-forward.toDouble(), 0),
                            end: Offset.zero,
                          )
                          .chain(CurveTween(curve: const Interval(0, .76)))
                          .animate(animation),
                  child: wallet,
                ),
              ),
            ),
          SlideTransition(
            position:
                Tween(begin: Offset.zero, end: Offset(forward.toDouble(), 0))
                    .chain(CurveTween(curve: const Interval(0, .76)))
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
      paths: _paths,
      geometry: _geometry,
      home: widget.builder(() => _go(true)),
    );
    if (!widget.enabled) return scene;
    return Column(
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: scene,
          ),
        ),
        CustomBottomNavigationBar(selectedIndex: 0, onTap: _selectTab),
      ],
    );
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
