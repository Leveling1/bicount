import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/app_press_theme.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/dropdown_chevron_theme.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

part 'wallet_classic_dropdown.dart';

class WalletPicker extends StatefulWidget {
  const WalletPicker({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.readOnly = false,
    this.useSharedMenu = false,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final bool useSharedMenu;

  @override
  State<WalletPicker> createState() => _WalletPickerState();
}

class _WalletPickerState extends State<WalletPicker> {
  final _wallets = BackendEnvironment.walletsEnabled
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
        useSharedMenu: widget.useSharedMenu,
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
    this.useSharedMenu = false,
  });

  final String label;
  final List<WalletModel> wallets;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool showPrincipalSelection;
  final bool useSharedMenu;

  @override
  Widget build(BuildContext context) {
    final available = wallets
        .where((w) => w.archivedAt == null || w.id == value)
        .toList();
    final change = onChanged;
    if (useSharedMenu && change != null) {
      return _buildSharedMenu(context, available, change);
    }
    return _WalletClassicDropdown(
      label: label,
      wallets: available,
      value: value,
      showPrincipalSelection: showPrincipalSelection,
      onChanged: change,
    );
  }

  Widget _buildSharedMenu(
    BuildContext context,
    List<WalletModel> available,
    ValueChanged<String> change,
  ) {
    final explicitIndex = available.indexWhere((wallet) => wallet.id == value);
    final selectedIndex = explicitIndex >= 0
        ? explicitIndex
        : available.indexWhere((wallet) => wallet.isDefault);
    final selected = selectedIndex < 0 ? null : available[selectedIndex];
    final selectedLabel = selected == null
        ? context.l10n.walletPrincipal
        : walletLabel(context, selected);

    return CustomDropdownMenu(
      key: ValueKey((selected?.id, selectedIndex, selectedLabel)),
      title: label,
      initialValue: selectedIndex,
      menuEntries: [
        if (selectedIndex < 0)
          DropdownMenuEntry(value: -1, label: selectedLabel, enabled: false),
        for (final (index, wallet) in available.indexed)
          DropdownMenuEntry(value: index, label: walletLabel(context, wallet)),
      ],
      onChanged: (index) {
        if (index != null && index >= 0) change(available[index].id);
      },
    );
  }
}

@Preview(name: 'Wallet picker', size: Size(AppSizes.dp360, AppSizes.dp90))
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
