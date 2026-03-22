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
    required this.onCreate,
    required this.onShare,
    required this.onCopy,
    required this.onScan,
  });

  final String title;
  final String description;
  final FriendShareEntity? activeShare;
  final bool isSubmitting;
  final VoidCallback onCreate;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
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
          if (activeShare != null) ...[
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusLarge,
                  ),
                ),
                child: QrImageView(
                  data: activeShare!.inviteUrl,
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
            if (activeShare!.isFriendProfileShare)
              Text(
                context.l10n.friendProfileShared(activeShare!.subjectName),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (activeShare!.isFriendProfileShare)
              const SizedBox(height: AppDimens.marginSmall),
            Text(
              activeShare!.inviteUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimens.marginMedium),
          ],
          Wrap(
            spacing: AppDimens.spacingMedium,
            runSpacing: AppDimens.spacingMedium,
            children: [
              ElevatedButton.icon(
                onPressed: isSubmitting ? null : onCreate,
                icon: const Icon(Icons.link_outlined),
                label: Text(
                  activeShare == null
                      ? context.l10n.friendShareGenerate
                      : context.l10n.friendShareRefresh,
                ),
              ),
              ElevatedButton.icon(
                onPressed: activeShare == null ? null : onShare,
                icon: const Icon(Icons.send_outlined),
                label: Text(context.l10n.friendShareLink),
              ),
              OutlinedButton.icon(
                onPressed: activeShare == null ? null : onCopy,
                icon: const Icon(Icons.copy_outlined),
                label: Text(context.l10n.commonCopy),
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
}
