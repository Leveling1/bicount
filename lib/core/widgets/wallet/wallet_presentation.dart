import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter/material.dart';

const _walletColors = [
  Colors.blueGrey,
  Colors.blue,
  Colors.teal,
  Colors.deepPurple,
  Colors.orange,
];

Color walletMetal(WalletModel? wallet) {
  if (wallet == null || wallet.isDefault) return const Color(0xFFCDC7BE);
  return walletFinishColor(wallet.color);
}

Color walletFinishColor(int index) {
  return switch (index) {
    0 => const Color(0xFFC2C7CE),
    4 => const Color(0xFFDBC28E),
    _ => Color.lerp(const Color(0xFFCDD0D1), _walletColors[index], .24)!,
  };
}

LinearGradient walletFinishGradient(Color metal) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: const [0, .38, .67, 1],
  colors: [
    Color.lerp(metal, Colors.white, .28)!,
    metal,
    Color.lerp(metal, Colors.white, .14)!,
    Color.lerp(metal, const Color(0xFF514A41), .14)!,
  ],
);

String walletKindLabel(BuildContext context, WalletKind kind) => switch (kind) {
  WalletKind.bankAccount => context.l10n.walletBank,
  WalletKind.cash => context.l10n.walletCash,
  WalletKind.card => context.l10n.walletCard,
  WalletKind.mobileMoney => context.l10n.walletMobile,
  WalletKind.other => context.l10n.walletOther,
};

String walletKindIcon(WalletKind kind) => switch (kind) {
  WalletKind.bankAccount => 'assets/icons/bank.svg',
  WalletKind.cash => 'assets/icons/piggy_bank.svg',
  WalletKind.card => 'assets/icons/credit_card.svg',
  WalletKind.mobileMoney => 'assets/icons/phone.svg',
  WalletKind.other => IconLinks.wallet,
};

String? walletNetworkLogo(WalletCardNetwork? network) => switch (network) {
  WalletCardNetwork.visa => 'assets/icons/visa.svg',
  WalletCardNetwork.mastercard => 'assets/icons/mastercard.svg',
  _ => null,
};

String walletOperatorLabel(WalletMobileOperator operator) => switch (operator) {
  WalletMobileOperator.mpesa => 'M-Pesa',
  WalletMobileOperator.orangeMoney => 'Orange Money',
  WalletMobileOperator.airtelMoney => 'Airtel Money',
  WalletMobileOperator.afrimoney => 'Afrimoney',
};

String walletOperatorLogo(WalletMobileOperator operator) =>
    'assets/icons/${operator.code}.svg';

String walletLabel(BuildContext context, WalletModel wallet) =>
    wallet.isDefault && wallet.name == 'Principal'
    ? context.l10n.walletPrincipal
    : wallet.name;
