import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'wallet_editor_choices.dart';

class WalletEditor extends StatefulWidget {
  const WalletEditor({super.key, this.wallet});
  final WalletModel? wallet;

  @override
  State<WalletEditor> createState() => _WalletEditorState();
}

class _WalletEditorState extends State<WalletEditor> {
  static final _nameLengthLimit = LengthLimitingTextInputFormatter(
    60,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
  );
  late final _name = TextEditingController(
    text: widget.wallet == null ? '' : walletLabel(context, widget.wallet!),
  )..addListener(_limitName);
  late var _kind = widget.wallet?.kind ?? WalletKind.other;
  late var _network = widget.wallet?.cardNetwork;
  late var _icon = widget.wallet?.icon ?? 0;
  late var _color = widget.wallet?.color ?? 0;
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _name.removeListener(_limitName);
    _name.dispose();
    super.dispose();
  }

  Future<void> _save({bool? archived}) async {
    if (_saving || _form.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      await WalletRepositoryImpl().save(
        existing: widget.wallet,
        name: _name.text,
        kind: _kind,
        network: _network,
        icon: _icon,
        color: _color,
        archived: archived ?? widget.wallet?.archivedAt != null,
      );
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.walletError)));
    }
  }

  void _limitName() {
    final value = _name.value;
    if (value.composing.isCollapsed && value.text.characters.length > 60) {
      _name.value = _nameLengthLimit.formatEditUpdate(
        TextEditingValue.empty,
        value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final types = [
      l10n.walletBank,
      l10n.walletCash,
      l10n.walletCard,
      l10n.walletMobile,
      l10n.walletOther,
    ];
    final fields = Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppDimens.spacingMedium,
        children: [
          WalletFormField(
            label: l10n.walletName,
            controller: _name,
            validator: (name) => name == null || name.trim().isEmpty
                ? l10n.validationFieldRequired
                : null,
          ),
          CustomDropdownMenu(
            title: l10n.walletKind,
            initialValue: _kind.index,
            menuEntries: [
              for (final kind in WalletKind.values)
                DropdownMenuEntry(value: kind.index, label: types[kind.index]),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _kind = WalletKind.values[value]);
              }
            },
          ),
          if (_kind == WalletKind.card)
            CustomDropdownMenu(
              title: l10n.walletNetwork,
              initialValue: _network?.index ?? -1,
              menuEntries: [
                const DropdownMenuEntry(value: -1, label: '—'),
                const DropdownMenuEntry(value: 0, label: 'Visa'),
                const DropdownMenuEntry(value: 1, label: 'Mastercard'),
                DropdownMenuEntry(value: 2, label: l10n.walletOther),
              ],
              onChanged: (value) => setState(
                () => _network = value == null || value == -1
                    ? null
                    : WalletCardNetwork.values[value],
              ),
            ),
          _WalletEditorChoices(
            label: l10n.walletIcon,
            selected: _icon,
            icons: walletIcons.map((icon) => Icon(icon)).toList(),
            onChanged: (value) => setState(() => _icon = value),
          ),
          _WalletEditorChoices(
            label: l10n.walletColor,
            selected: _color,
            icons: walletColors
                .map((color) => Icon(Icons.circle, color: color))
                .toList(),
            onChanged: (value) => setState(() => _color = value),
          ),
        ],
      ),
    );
    final wallet = widget.wallet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingMedium,
      children: [
        Text(
            wallet == null ? l10n.walletNew : l10n.walletEdit,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        fields,
        CustomButton(text: l10n.commonSave, loading: _saving, onPressed: _save),
        if (wallet != null && !wallet.isDefault)
          TextButton(
            onPressed: _saving
                ? null
                : () => _save(archived: wallet.archivedAt == null),
            child: Text(
              wallet.archivedAt == null
                  ? l10n.walletArchive
                  : l10n.walletRestore,
            ),
          ),
        const SizedBox(),
      ],
    );
  }
}
