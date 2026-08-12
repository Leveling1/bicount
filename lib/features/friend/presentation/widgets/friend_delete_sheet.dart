import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/friend/domain/entities/friend_link_entities.dart';
import 'package:bicount/features/friend/presentation/widgets/friend_consequence_row.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Confirmation for permanently deleting an unlinked profile. The counts are
/// computed before anything is shown, so the warning names exactly what is
/// about to disappear instead of a vague "related data".
class FriendDeleteSheet extends StatefulWidget {
  const FriendDeleteSheet({super.key, required this.friend});

  final FriendsModel friend;

  @override
  State<FriendDeleteSheet> createState() => _FriendDeleteSheetState();
}

class _FriendDeleteSheetState extends State<FriendDeleteSheet> {
  FriendDeletionImpact? _impact;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadImpact();
  }

  Future<void> _loadImpact() async {
    try {
      final impact = await context
          .read<FriendRepositoryImpl>()
          .friendDeletionImpact(widget.friend);
      if (mounted) {
        setState(() => _impact = impact);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _impact = const FriendDeletionImpact.empty());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.friend.username;
    final impact = _impact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.friendDeleteTitle(name),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppDimens.spacerSmall,
        Text(
          context.l10n.friendDeleteIntro(name),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppDimens.spacerMedium,
        if (impact == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.paddingLarge),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          )
        else ...[
          if (impact.isEmpty)
            FriendConsequenceRow(
              icon: Icons.info_outline,
              text: context.l10n.friendDeleteNothingRecorded(name),
            )
          else ...[
            if (impact.transactionCount > 0)
              FriendConsequenceRow(
                icon: Icons.receipt_long_outlined,
                tone: FriendConsequenceTone.danger,
                text: context.l10n.friendDeleteTransactions(
                  impact.transactionCount,
                ),
              ),
            if (impact.debtCount > 0)
              FriendConsequenceRow(
                icon: Icons.handshake_outlined,
                tone: FriendConsequenceTone.danger,
                text: context.l10n.friendDeleteDebts(impact.debtCount),
              ),
            if (impact.recurringCount > 0)
              FriendConsequenceRow(
                icon: Icons.event_repeat_outlined,
                tone: FriendConsequenceTone.danger,
                text: context.l10n.friendDeleteRecurring(impact.recurringCount),
              ),
            FriendConsequenceRow(
              icon: Icons.account_balance_wallet_outlined,
              tone: FriendConsequenceTone.danger,
              text: context.l10n.friendDeleteBalanceWarning,
            ),
          ],
          FriendConsequenceRow(
            icon: Icons.lock_outline,
            tone: FriendConsequenceTone.danger,
            text: context.l10n.friendDeleteIrreversible,
          ),
          FriendConsequenceRow(
            icon: Icons.lightbulb_outline,
            text: context.l10n.friendDeleteKeepHint,
          ),
          AppDimens.spacerMedium,
          CustomButton(
            text: context.l10n.friendDeleteConfirm,
            loading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
        AppDimens.spacerSmall,
        CustomOutlinedButton(
          onPressed: _isSubmitting ? () {} : () => Navigator.of(context).pop(),
          text: context.l10n.commonCancel,
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
      await context.read<FriendRepositoryImpl>().deleteFriendWithHistory(
        widget.friend,
      );
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
          : 'Unable to delete this profile right now.';
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
