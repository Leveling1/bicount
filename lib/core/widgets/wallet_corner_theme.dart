import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class WalletCornerTheme extends StatelessWidget {
  const WalletCornerTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: AppTheme.walletCorners(Theme.of(context)), child: child);
  }
}
