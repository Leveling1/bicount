import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletBalanceText extends StatelessWidget {
  const WalletBalanceText({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WalletBloc, WalletState, (double?, String)>(
      selector: (state) => (
        state.totalFor(walletId),
        state.currencyConfig.referenceCurrencyCode,
      ),
      builder: (context, value) {
        final label = value.$1 == null
            ? '—'
            : NumberFormatUtils.formatCurrency(
                value.$1!,
                currencyCode: value.$2,
              );
        return Semantics(
          label: '${context.l10n.walletBalance}: $label',
          excludeSemantics: true,
          child: Text(label, maxLines: 1),
        );
      },
    );
  }
}
