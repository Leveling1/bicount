import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';

class WalletEditor extends StatefulWidget {
  const WalletEditor({super.key, this.wallet});
  final WalletModel? wallet;

  @override
  State<WalletEditor> createState() => _WalletEditorState();
}

class _WalletEditorState extends State<WalletEditor> {
  late final _name = TextEditingController(
    text: widget.wallet == null ? '' : walletLabel(context, widget.wallet!),
  );
  late var _kind = widget.wallet?.kind ?? WalletKind.other;
  late var _network = widget.wallet?.cardNetwork;
  late var _icon = widget.wallet?.icon ?? 0;
  late var _color = widget.wallet?.color ?? 0;
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save({bool? archived}) async {
    if (!_form.currentState!.validate()) return;
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
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.walletError)));
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
    final archived = widget.wallet?.archivedAt != null;
    return AlertDialog(
      title: Text(widget.wallet == null ? l10n.walletNew : l10n.walletEdit),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 60,
                decoration: InputDecoration(labelText: l10n.walletName),
                validator: (name) => name == null || name.trim().isEmpty
                    ? l10n.validationFieldRequired
                    : null,
              ),
              DropdownButtonFormField<WalletKind>(
                initialValue: _kind,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.walletKind),
                items: [
                  for (final kind in WalletKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(types[kind.index]),
                    ),
                ],
                onChanged: (value) => setState(() => _kind = value!),
              ),
              if (_kind == WalletKind.card)
                DropdownButtonFormField<int>(
                  initialValue: _network?.index ?? -1,
                  decoration: InputDecoration(labelText: l10n.walletNetwork),
                  items: [
                    const DropdownMenuItem(value: -1, child: Text('—')),
                    const DropdownMenuItem(value: 0, child: Text('Visa')),
                    const DropdownMenuItem(value: 1, child: Text('Mastercard')),
                    DropdownMenuItem(value: 2, child: Text(l10n.walletOther)),
                  ],
                  onChanged: (value) => setState(
                    () => _network = value == -1
                        ? null
                        : WalletCardNetwork.values[value!],
                  ),
                ),
              AppDimens.spacerMedium,
              _choices(
                l10n.walletIcon,
                _icon,
                walletIcons.map((icon) => Icon(icon)).toList(),
                (value) => setState(() => _icon = value),
              ),
              _choices(
                l10n.walletColor,
                _color,
                walletColors
                    .map((color) => Icon(Icons.circle, color: color))
                    .toList(),
                (value) => setState(() => _color = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.wallet != null && !widget.wallet!.isDefault)
          TextButton(
            onPressed: _saving ? null : () => _save(archived: !archived),
            child: Text(archived ? l10n.walletRestore : l10n.walletArchive),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }

  Widget _choices(
    String label,
    int selected,
    List<Widget> icons,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: AppDimens.spacingSmall,
          children: [
            for (final (index, icon) in icons.indexed)
              ChoiceChip(
                label: icon,
                showCheckmark: false,
                selected: index == selected,
                onSelected: (_) => onChanged(index),
              ),
          ],
        ),
      ],
    );
  }
}
