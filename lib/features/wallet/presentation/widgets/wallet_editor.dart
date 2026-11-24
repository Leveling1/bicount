import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_form_field.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor_preview.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'wallet_editor_choices.dart';
part 'wallet_editor_providers.dart';

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
  late var _operator = widget.wallet?.mobileOperator;
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
        mobileOperator: _operator,
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
    final wallet = widget.wallet;
    final fields = Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppDimens.spacingMedium,
        children: [
          Padding(
            padding: WalletEditorLayout.horizontalInset,
            child: WalletFormField(
              label: l10n.walletName,
              controller: _name,
              validator: (name) => name == null || name.trim().isEmpty
                  ? l10n.validationFieldRequired
                  : null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WalletIconChoices<WalletKind>(
                title: l10n.walletKind,
                selected: _kind,
                options: [
                  for (final kind in WalletKind.values)
                    (
                      value: kind,
                      label: walletKindLabel(context, kind),
                      svg: walletKindIcon(kind),
                    ),
                ],
                onChanged: (kind) => setState(() => _kind = kind),
              ),
              _WalletProviderSection(
                kind: _kind,
                network: _network,
                operator: _operator,
                onNetworkChanged: (network) =>
                    setState(() => _network = network),
                onOperatorChanged: (operator) =>
                    setState(() => _operator = operator),
              ),
            ],
          ),
          if (wallet?.isDefault != true)
            Padding(
              padding: WalletEditorLayout.horizontalInset,
              child: _WalletColorChoices(
                selected: _color,
                onChanged: (color) => setState(() => _color = color),
              ),
            ),
        ],
      ),
    );
    return WalletEditorLayout(
      title: wallet == null ? l10n.walletNew : l10n.walletEdit,
      preview: WalletEditorPreview(
        name: _name,
        wallet: wallet,
        kind: _kind,
        network: _network,
        mobileOperator: _operator,
        color: _color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppDimens.spacingMedium,
        children: [
          fields,
          Padding(
            padding: WalletEditorLayout.horizontalInset,
            child: CustomButton(
              text: l10n.commonSave,
              loading: _saving,
              onPressed: _save,
            ),
          ),
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
      ),
    );
  }
}
