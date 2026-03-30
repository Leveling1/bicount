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
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionUnsubscribed) {
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
          isUnsubscribing: state is SubscriptionUnsubscribing,
          onEditPressed: () => setState(() => _isEditing = true),
          onUnsubscribePressed: () => context.read<SubscriptionBloc>().add(
            UnsubscribeRequested(widget.subscription),
          ),
        );
      },
    );
  }
}
