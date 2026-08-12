import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FriendShareCard extends StatelessWidget {
  const FriendShareCard({
    super.key,
    required this.title,
    required this.description,
    required this.activeShare,
    required this.isSubmitting,
    required this.isPreparing,
    required this.onCreate,
    required this.onShare,
    required this.onCopy,
    required this.onScan,
  });

  static const _qrSize = 180.0;

  final String title;
  final String description;
  final FriendShareEntity? activeShare;
  final bool isSubmitting;

  /// The code is on its way. Distinguishes "still working on it" from "it did
  /// not work, use the button", so the card never spins forever.
  final bool isPreparing;
  final VoidCallback onCreate;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final share = activeShare;

    return DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppDimens.marginLarge),
          if (share == null)
            _buildPlaceholder(context)
          else ...[
            _buildQrCode(context, share),
            const SizedBox(height: AppDimens.marginMedium),
            if (share.isFriendProfileShare)
              Text(
                context.l10n.friendProfileShared(share.subjectName),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (share.isFriendProfileShare)
              const SizedBox(height: AppDimens.marginSmall),
            Text(share.inviteUrl, style: Theme.of(context).textTheme.bodySmall),
            if (!share.isSynced) ...[
              const SizedBox(height: AppDimens.marginMedium),
              _buildOfflineNotice(context),
            ],
            const SizedBox(height: AppDimens.marginMedium),
          ],
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              if (share != null) ...[
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(context.l10n.friendShareLink),
                ),
                OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(context.l10n.commonCopy),
                ),
              ],
              OutlinedButton.icon(
                onPressed: isSubmitting ? null : onCreate,
                icon: const Icon(Icons.autorenew_outlined),
                label: Text(
                  share == null
                      ? context.l10n.friendShareGenerate
                      : context.l10n.friendShareRefresh,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: Text(context.l10n.friendShareScanQr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode(BuildContext context, FriendShareEntity share) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
        child: QrImageView(
          data: share.inviteUrl,
          size: _qrSize,
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
    );
  }

  /// Shown while the code is being prepared, so the card never looks empty or
  /// like it is waiting for a tap. When preparing has stopped without a code,
  /// the spinner gives way to a message pointing at the button.
  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Container(
        width: _qrSize + (AppDimens.paddingMedium * 2),
        height: _qrSize + (AppDimens.paddingMedium * 2),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPreparing)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            else
              Icon(
                Icons.qr_code_2_outlined,
                size: 28,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            const SizedBox(height: AppDimens.marginMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: Text(
                isPreparing
                    ? context.l10n.friendSharePreparing
                    : context.l10n.friendShareUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineNotice(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wifi_off_outlined, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.friendShareOfflineNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
