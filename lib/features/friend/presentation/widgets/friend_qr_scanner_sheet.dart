import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FriendQrScannerSheet extends StatefulWidget {
  const FriendQrScannerSheet({super.key, required this.onValue});

  final ValueChanged<String> onValue;

  @override
  State<FriendQrScannerSheet> createState() => _FriendQrScannerSheetState();
}

class _FriendQrScannerSheetState extends State<FriendQrScannerSheet> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.borderRadiusExtraLarge),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimens.marginMedium),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
          Text(
            context.l10n.friendScanQrTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.marginMedium),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimens.borderRadiusExtraLarge,
              ),
              child: MobileScanner(
                onDetect: (capture) {
                  if (_handled) {
                    return;
                  }
                  final value = capture.barcodes.first.rawValue;
                  if (value == null || value.isEmpty) {
                    return;
                  }
                  _handled = true;
                  widget.onValue(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimens.marginLarge),
        ],
      ),
    );
  }
}
