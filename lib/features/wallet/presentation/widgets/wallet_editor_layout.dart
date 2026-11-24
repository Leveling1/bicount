import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class WalletEditorLayout extends StatelessWidget {
  const WalletEditorLayout({
    super.key,
    required this.title,
    required this.preview,
    required this.child,
  });

  final String title;
  final Widget preview;
  final Widget child;

  static const horizontalInset = EdgeInsets.symmetric(horizontal: 25);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: horizontalInset,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * .48,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        key: const ValueKey('wallet-editor-title'),
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingMedium),
                  Flexible(flex: 4, child: preview),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spacingMedium),
          Flexible(
            child: SingleChildScrollView(
              key: const ValueKey('wallet-editor-fields'),
              primary: false,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
