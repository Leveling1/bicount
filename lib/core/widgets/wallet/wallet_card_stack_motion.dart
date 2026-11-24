part of 'wallet_card_stack.dart';

extension _WalletCardStackMotion on _WalletCardStackState {
  Widget _buildCards(
    double page,
    double width,
    double height,
    int layers,
    int direction,
    bool reduceMotion,
  ) {
    final currentPage = page >= _restingPage ? page.floor() : page.ceil();
    final offset = page - currentPage;
    final current = _walletIndex(currentPage);
    final next = _walletIndex(
      (currentPage + offset.sign.toInt()).clamp(0, _pageCount - 1),
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
              -_WalletCardStackState._depth *
                  (layer - (layer == 1 ? progress : 0)),
            ),
            child: Transform.scale(
              scale: 1 - .035 * (layer - (layer == 1 ? progress : 0)),
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
  }

  Widget _face(int index, double height, {required bool foreground}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: WalletCardFace(
        wallet: widget.wallets[index],
        balance: widget.balanceBuilder?.call(widget.wallets[index]),
        showDetails: foreground,
      ),
    );
  }
}
