part of 'wallet_editor.dart';

class _WalletProviderSection extends StatelessWidget {
  const _WalletProviderSection({
    required this.kind,
    required this.network,
    required this.operator,
    required this.onNetworkChanged,
    required this.onOperatorChanged,
  });

  final WalletKind kind;
  final WalletCardNetwork? network;
  final WalletMobileOperator? operator;
  final ValueChanged<WalletCardNetwork?> onNetworkChanged;
  final ValueChanged<WalletMobileOperator?> onOperatorChanged;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    final options = _options(context);
    return ClipRect(
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: duration,
        curve: Curves.easeInOutCubic,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          // Let the incoming field set the height while the old one fades out.
          layoutBuilder: (current, previous) => Stack(
            children: [
              for (final child in previous)
                Positioned(
                  key: child.key,
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ExcludeFocus(
                    child: ExcludeSemantics(child: IgnorePointer(child: child)),
                  ),
                ),
              current ?? const SizedBox(width: double.infinity),
            ],
          ),
          child: options == null
              ? null
              : Padding(
                  key: ValueKey(kind),
                  padding: const EdgeInsets.only(top: AppDimens.spacingMedium),
                  child: options,
                ),
        ),
      ),
    );
  }

  Widget? _options(BuildContext context) {
    final l10n = context.l10n;
    return switch (kind) {
      WalletKind.card => _WalletIconChoices<WalletCardNetwork?>(
        title: l10n.walletNetwork,
        selected: network == WalletCardNetwork.other ? null : network,
        options: [
          (value: null, label: l10n.walletNoProvider, svg: null),
          for (final (value, label) in [
            (WalletCardNetwork.visa, 'Visa'),
            (WalletCardNetwork.mastercard, 'Mastercard'),
          ])
            (value: value, label: label, svg: walletNetworkLogo(value)),
        ],
        onChanged: onNetworkChanged,
      ),
      WalletKind.mobileMoney => _WalletIconChoices<WalletMobileOperator?>(
        title: l10n.walletMobileOperator,
        selected: operator,
        options: [
          (value: null, label: l10n.walletNoProvider, svg: null),
          for (final value in WalletMobileOperator.values)
            (
              value: value,
              label: walletOperatorLabel(value),
              svg: walletOperatorLogo(value),
            ),
        ],
        onChanged: onOperatorChanged,
      ),
      _ => null,
    };
  }
}
