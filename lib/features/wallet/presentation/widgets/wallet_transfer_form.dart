import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTransferForm extends StatefulWidget {
  const WalletTransferForm({
    super.key,
    required this.wallets,
    required this.repository,
  });

  final List<WalletModel> wallets;
  final WalletRepository repository;

  @override
  State<WalletTransferForm> createState() => _WalletTransferFormState();
}

class _WalletTransferFormState extends State<WalletTransferForm> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late String _source = widget.wallets.first.id;
  late String _target = widget.wallets[1].id;
  final _currency = TextEditingController();
  bool _saving = false;

  double? get _value =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _form.currentState?.validate() != true) return;
    if (_source == _target) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.walletDifferent)));
      return;
    }
    final currency = _currency.text.isEmpty
        ? context.read<CurrencyCubit>().state.config.referenceCurrencyCode
        : _currency.text;
    setState(() => _saving = true);
    try {
      await widget.repository.transfer(
        from: widget.wallets.firstWhere((wallet) => wallet.id == _source),
        to: widget.wallets.firstWhere((wallet) => wallet.id == _target),
        amount: _value!,
        currency: currency,
        title: context.l10n.walletTransfer,
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppDimens.spacingMedium,
        children: [
          Text(
            l10n.walletTransfer,
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          WalletDropdown(
            label: l10n.walletFrom,
            useSharedMenu: true,
            wallets: widget.wallets,
            value: _source,
            onChanged: (id) => setState(() => _source = id),
          ),
          WalletDropdown(
            label: l10n.walletTo,
            useSharedMenu: true,
            wallets: widget.wallets,
            value: _target,
            onChanged: (id) => setState(() => _target = id),
          ),
          FormField<double>(
            validator: (_) {
              final value = _value;
              return value == null || !value.isFinite || value < .01
                  ? l10n.validationAmountGreaterThanZero
                  : null;
            },
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppDimens.spacingExtraSmall,
              children: [
                CustomAmountField(amount: _amount, currency: _currency),
                if (field.errorText case final error?)
                  Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          CustomButton(
            text: l10n.commonSave,
            loading: _saving,
            onPressed: _save,
          ),
          AppDimens.spacerSmall,
        ],
      ),
    );
  }
}
