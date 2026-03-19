import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/features/friend/domain/entities/friend_invite_entity.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_qr_scanner_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

void handleFriendStateFeedback(BuildContext context, FriendState state) {
  if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
    NotificationHelper.showFailureNotification(context, state.errorMessage!);
  }
  if (state.flashMessage != null && state.flashMessage!.isNotEmpty) {
    NotificationHelper.showSuccessNotification(context, state.flashMessage!);
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

  NotificationHelper.showSuccessNotification(context, 'Invitation link copied.');
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

Future<void> shareFriendInvite(FriendShareEntity? share) async {
  if (share == null) {
    return;
  }

  final label = share.isFriendProfileShare
      ? share.subjectName
      : 'my Bicount profile';
  await Share.share(
    'Join me on Bicount and link the profile for $label: ${share.inviteUrl}',
  );
}
