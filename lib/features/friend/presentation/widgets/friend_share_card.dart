import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FriendShareCard extends StatelessWidget {
  const FriendShareCard({
    super.key,
    required this.state,
    required this.onCreate,
    required this.onShare,
    required this.onCopy,
    required this.onScan,
  });

  final FriendState state;
  final VoidCallback onCreate;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final activeShare = state.hub.activeShare;

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share your profile',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate a reusable invitation, then share it as a link or a QR code.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.marginLarge),
          if (activeShare != null) ...[
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
                ),
                child: QrImageView(
                  data: activeShare.inviteUrl,
                  size: 180,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).primaryColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.marginMedium),
            Text(activeShare.inviteUrl, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimens.marginMedium),
          ],
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              ElevatedButton.icon(
                onPressed: state.isSubmitting ? null : onCreate,
                icon: const Icon(Icons.link_outlined),
                label: Text(activeShare == null ? 'Generate invite' : 'Refresh'),
              ),
              ElevatedButton.icon(
                onPressed: activeShare == null ? null : onShare,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Share link'),
              ),
              OutlinedButton.icon(
                onPressed: activeShare == null ? null : onCopy,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy'),
              ),
              OutlinedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Scan QR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
