import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class WalletPicker extends StatefulWidget {
  const WalletPicker({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.readOnly = false,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  State<WalletPicker> createState() => _WalletPickerState();
}

class _WalletPickerState extends State<WalletPicker> {
  final _wallets = BackendEnvironment.isLocalPreproduction
      ? WalletRepositoryImpl().watch()
      : null;

  @override
  Widget build(BuildContext context) {
    if (_wallets == null) return const SizedBox.shrink();
    return StreamBuilder<List<WalletModel>>(
      stream: _wallets,
      builder: (context, snapshot) => WalletDropdown(
        label: widget.label,
        wallets: snapshot.data ?? const [],
        value: widget.value,
        onChanged: widget.readOnly ? null : widget.onChanged,
      ),
    );
  }
}

class WalletDropdown extends StatelessWidget {
  const WalletDropdown({
    super.key,
    required this.label,
    required this.wallets,
    required this.onChanged,
    this.value,
    this.showPrincipalSelection = true,
  });

  final String label;
  final List<WalletModel> wallets;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool showPrincipalSelection;

  @override
  Widget build(BuildContext context) {
    final available = wallets
        .where((w) => w.archivedAt == null || w.id == value)
        .toList();
    final selected = available.any((wallet) => wallet.id == value)
        ? value
        : null;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          value: selected,
          hint: showPrincipalSelection
              ? Text(
                  available
                          .where((wallet) => wallet.isDefault)
                          .map((wallet) => walletLabel(context, wallet))
                          .firstOrNull ??
                      context.l10n.walletPrincipal,
                )
              : null,
          items: [
            for (final wallet in available)
              DropdownMenuItem(
                value: wallet.id,
                child: Text(
                  walletLabel(context, wallet),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged == null
              ? null
              : (id) {
                  if (id != null) onChanged!(id);
                },
        ),
      ),
    );
  }
}

String walletLabel(BuildContext context, WalletModel wallet) =>
    wallet.isDefault && wallet.name == 'Principal'
    ? context.l10n.walletPrincipal
    : wallet.name;

@Preview(name: 'Wallet picker', size: Size(360, 90))
Widget walletPickerPreview() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: WalletDropdown(
      label: 'Pay from',
      wallets: const [
        WalletModel(
          id: 'bank',
          ownerUid: 'preview',
          name: 'Visa',
          createdAt: '',
        ),
      ],
      value: 'bank',
      onChanged: (_) {},
    ),
  ),
);
