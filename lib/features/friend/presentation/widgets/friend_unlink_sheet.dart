import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_consequence_row.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Confirmation for breaking the link between two accounts. Nothing is
/// deleted here, and the wording says so plainly: the fear this screen has to
/// answer is "am I about to lose my history?".
class FriendUnlinkSheet extends StatefulWidget {
  const FriendUnlinkSheet({super.key, required this.friend});

  final FriendsModel friend;

  @override
  State<FriendUnlinkSheet> createState() => _FriendUnlinkSheetState();
}

class _FriendUnlinkSheetState extends State<FriendUnlinkSheet> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.friend.username;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.friendUnlinkTitle(name),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppDimens.spacerSmall,
        Text(
          context.l10n.friendUnlinkIntro,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppDimens.spacerMedium,
        FriendConsequenceRow(
          icon: Icons.check_circle_outline,
          tone: FriendConsequenceTone.safe,
          text: context.l10n.friendUnlinkKeepYours,
        ),
        FriendConsequenceRow(
          icon: Icons.check_circle_outline,
          tone: FriendConsequenceTone.safe,
          text: context.l10n.friendUnlinkKeepTheirs(name),
        ),
        FriendConsequenceRow(
          icon: Icons.visibility_off_outlined,
          text: context.l10n.friendUnlinkStopSharing(name),
        ),
        FriendConsequenceRow(
          icon: Icons.replay_outlined,
          tone: FriendConsequenceTone.safe,
          text: context.l10n.friendUnlinkReversible,
        ),
        AppDimens.spacerMedium,
        CustomButton(
          text: context.l10n.friendUnlinkConfirm,
          loading: _isSubmitting,
          onPressed: _submit,
        ),
        AppDimens.spacerSmall,
        CustomOutlinedButton(
          onPressed: _isSubmitting ? () {} : () => Navigator.of(context).pop(),
          text: 'context.l10n.commonCancel',
          loading: false,
        ),
        AppDimens.spacerLarge,
      ],
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      await context.read<FriendRepositoryImpl>().unlinkFriend(widget.friend);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is Failure
          ? error.message
          : 'Unable to separate these accounts right now.';
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, message),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
