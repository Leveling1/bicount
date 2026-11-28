part of 'wallet_picker.dart';

class _WalletClassicDropdown extends StatelessWidget {
  const _WalletClassicDropdown({
    required this.label,
    required this.wallets,
    required this.value,
    required this.showPrincipalSelection,
    required this.onChanged,
  });

  final String label;
  final List<WalletModel> wallets;
  final String? value;
  final bool showPrincipalSelection;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final change = onChanged;
    final selected = wallets.any((wallet) => wallet.id == value) ? value : null;
    final theme = Theme.of(context);
    final tint = appPressedColor(theme.primaryColor);
    final fill = theme.inputDecorationTheme.fillColor ?? Colors.transparent;

    Widget walletText(WalletModel wallet) =>
        Text(walletLabel(context, wallet), overflow: TextOverflow.ellipsis);

    return Theme(
      data: theme.copyWith(
        // The stock InkWell covers the whole route row. The row below paints
        // its own rounded tint while the dropdown keeps handling taps.
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: BicountPressable.control(
        enabled: change != null && wallets.isNotEmpty,
        controlBuilder: (context, pressed) => InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            filled: pressed ? true : null,
            fillColor: pressed ? Color.alphaBlend(tint, fill) : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              icon: DropdownChevronTheme.of(context).icon(),
              value: selected,
              hint: showPrincipalSelection
                  ? Text(
                      wallets
                              .where((wallet) => wallet.isDefault)
                              .map((wallet) => walletLabel(context, wallet))
                              .firstOrNull ??
                          context.l10n.walletPrincipal,
                    )
                  : null,
              selectedItemBuilder: (context) => [
                for (final wallet in wallets)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: walletText(wallet),
                  ),
              ],
              items: [
                for (final wallet in wallets)
                  DropdownMenuItem(
                    value: wallet.id,
                    child: BicountPressable.control(
                      controlBuilder: (context, pressed) => DecoratedBox(
                        decoration: ShapeDecoration(
                          color: pressed ? tint : Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimens.borderRadiusMedium),
                            ),
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: walletText(wallet),
                        ),
                      ),
                    ),
                  ),
              ],
              onChanged: change == null
                  ? null
                  : (id) {
                      if (id != null) change(id);
                    },
            ),
          ),
        ),
      ),
    );
  }
}
