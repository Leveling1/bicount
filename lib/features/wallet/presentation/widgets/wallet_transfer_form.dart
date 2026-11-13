import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTransferForm extends StatefulWidget {
  const WalletTransferForm({super.key, required this.wallets});

  final List<WalletModel> wallets;

  @override
  State<WalletTransferForm> createState() => _WalletTransferFormState();
}

class _WalletTransferFormState extends State<WalletTransferForm> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late String _source = widget.wallets.first.id;
  late String _target = widget.wallets[1].id;
  String? _currency;
  bool _saving = false;

  double? get _value =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(String currency) async {
    if (!_form.currentState!.validate()) return;
    if (_source == _target) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.walletDifferent)));
      return;
    }
    setState(() => _saving = true);
    try {
      await WalletRepositoryImpl().transfer(
        from: widget.wallets.firstWhere((wallet) => wallet.id == _source),
        to: widget.wallets.firstWhere((wallet) => wallet.id == _target),
        amount: _value!,
        currency: currency,
        title: context.l10n.walletTransfer,
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
    final config = context.watch<CurrencyCubit>().state.config;
    final currency = _currency ?? config.referenceCurrencyCode;
    final currencies = {
      ...config.currencies.map((item) => item.code),
      currency,
    };
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.walletTransfer),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WalletDropdown(
                label: l10n.walletFrom,
                wallets: widget.wallets,
                value: _source,
                onChanged: (id) => setState(() => _source = id),
              ),
              AppDimens.spacerSmall,
              WalletDropdown(
                label: l10n.walletTo,
                wallets: widget.wallets,
                value: _target,
                onChanged: (id) => setState(() => _target = id),
              ),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.walletBalance),
                validator: (_) {
                  final value = _value;
                  return value == null || !value.isFinite || value < .01
                      ? l10n.validationFieldRequired
                      : null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: currency,
                items: [
                  for (final code in currencies)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (code) => setState(() => _currency = code),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _save(currency),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
