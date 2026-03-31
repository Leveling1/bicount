import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_detail_view.dart';
import 'package:bicount/features/subscription/presentation/widgets/subscription_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailSubscription extends StatefulWidget {
  const DetailSubscription({
    super.key,
    required this.friend,
    required this.subscription,
  });

  final FriendsModel friend;
  final SubscriptionModel subscription;

  @override
  State<DetailSubscription> createState() => _DetailSubscriptionState();
}

class _DetailSubscriptionState extends State<DetailSubscription> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final canManage =
        currentUserId == widget.subscription.sid &&
        widget.subscription.sid.isNotEmpty;

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listenWhen: (previous, current) =>
          current is SubscriptionDeleted ||
          current is SubscriptionUnsubscribed ||
          (!_isEditing && current is SubscriptionFailure),
      listener: (context, state) {
        if (state is SubscriptionDeleted) {
          NotificationHelper.showSuccessNotification(
            context,
            context.l10n.subscriptionDeletedSuccess,
          );
          Navigator.of(context).maybePop();
        } else if (state is SubscriptionUnsubscribed) {
          NotificationHelper.showSuccessNotification(
            context,
            context.l10n.subscriptionUnsubscribeSuccess,
          );
          Navigator.of(context).maybePop();
        } else if (state is SubscriptionFailure) {
          NotificationHelper.showFailureNotification(
            context,
            localizeRuntimeMessage(context, state.message),
          );
        }
      },
      builder: (context, state) {
        if (_isEditing) {
          return SubscriptionForm(
            initialSubscription: widget.subscription,
            onCompleted: () => Navigator.of(context).maybePop(),
          );
        }

        return SubscriptionDetailView(
          friend: widget.friend,
          subscription: widget.subscription,
          canManage: canManage,
          isDeleting: state is SubscriptionDeleting,
          isUnsubscribing: state is SubscriptionUnsubscribing,
          onDeletePressed: canManage ? () => _confirmDelete(context) : null,
          onEditPressed: canManage
              ? () => setState(() => _isEditing = true)
              : null,
          onUnsubscribePressed: canManage
              ? () => context.read<SubscriptionBloc>().add(
                  UnsubscribeRequested(widget.subscription),
                )
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: Theme.of(dialogContext).dialogTheme.shape,
        title: Text(context.l10n.subscriptionDeleteConfirmTitle),
        content: Text(context.l10n.subscriptionDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonReject),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.subscriptionDeleteConfirmCta),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SubscriptionBloc>().add(
        DeleteSubscriptionRequested(widget.subscription),
      );
    }
  }
}
