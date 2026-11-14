import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter/material.dart';

const walletIcons = [
  Icons.account_balance_wallet_outlined,
  Icons.account_balance_outlined,
  Icons.payments_outlined,
  Icons.credit_card_outlined,
  Icons.phone_android,
];
const walletColors = [
  Colors.blueGrey,
  Colors.blue,
  Colors.teal,
  Colors.deepPurple,
  Colors.orange,
];

Color walletMetal(WalletModel? wallet) {
  if (wallet == null || wallet.isDefault) return const Color(0xFFCDC7BE);
  return switch (wallet.color) {
    0 => const Color(0xFFC2C7CE),
    4 => const Color(0xFFDBC28E),
    final index => Color.lerp(
      const Color(0xFFCDD0D1),
      walletColors[index],
      .24,
    )!,
  };
}

String walletLabel(BuildContext context, WalletModel wallet) =>
    wallet.isDefault && wallet.name == 'Principal'
    ? context.l10n.walletPrincipal
    : wallet.name;
