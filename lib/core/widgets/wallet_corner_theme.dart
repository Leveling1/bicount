import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class WalletCornerTheme extends StatelessWidget {
  const WalletCornerTheme({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: enabled ? AppTheme.walletCorners(theme) : theme,
      child: child,
    );
  }
}
