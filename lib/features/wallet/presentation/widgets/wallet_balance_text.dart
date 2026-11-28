import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/currency/domain/entities/app_currency_entity.dart';
import 'package:bicount/features/wallet/domain/services/wallet_balance_total.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletBalanceText extends StatelessWidget {
  const WalletBalanceText({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      WalletBloc,
      WalletState,
      (WalletBalanceValuation?, String, List<AppCurrencyEntity>)
    >(
      selector: (state) => (
        state.balanceFor(walletId),
        state.currencyConfig.referenceCurrencyCode,
        state.currencyConfig.currencies,
      ),
      builder: (context, value) {
        final (balance, currencyCode, _) = value;
        final amount = balance?.amount;
        final missingRates = balance?.missingRates;
        final label = amount != null
            ? NumberFormatUtils.formatCurrency(
                amount,
                currencyCode: currencyCode,
              )
            : missingRates == null
            ? '—'
            : context.l10n.walletBalanceMissingRates(missingRates);
        return Semantics(
          label: '${context.l10n.walletBalance}: $label',
          excludeSemantics: true,
          child: Text(label, maxLines: 1),
        );
      },
    );
  }
}
