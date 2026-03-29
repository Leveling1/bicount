import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_qr_scanner_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

void handleFriendStateFeedback(BuildContext context, FriendState state) {
  if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
    NotificationHelper.showFailureNotification(
      context,
      localizeRuntimeMessage(context, state.errorMessage!),
    );
  }
  if (state.flashMessage != null && state.flashMessage!.isNotEmpty) {
    NotificationHelper.showSuccessNotification(
      context,
      localizeRuntimeMessage(context, state.flashMessage!),
    );
  }
}

Future<void> copyFriendInvite(
  BuildContext context,
  FriendShareEntity? share,
) async {
  if (share == null) {
    return;
  }

  await Clipboard.setData(ClipboardData(text: share.inviteUrl));
  if (!context.mounted) {
    return;
  }

  NotificationHelper.showSuccessNotification(
    context,
    context.l10n.friendInvitationLinkCopied,
  );
}

Future<void> openFriendScanner(
  BuildContext context, {
  required ValueChanged<String> onValue,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FriendQrScannerSheet(onValue: onValue),
  );
}

Future<void> shareFriendInvite(
  BuildContext context,
  FriendShareEntity? share,
) async {
  if (share == null) {
    return;
  }

  final label = share.isFriendProfileShare
      ? share.subjectName
      : context.l10n.friendMyProfile;
  final message = context.l10n.friendShareMessage(label, share.inviteUrl);
  await Share.share(message);
}
