import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/friend/presentation/screens/friend_screen.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_app_bar.dart';

class FriendInviteLandingScreen extends StatelessWidget {
  const FriendInviteLandingScreen({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.friendInviteLandingTitle),
      body: FriendScreen(initialInviteCode: inviteCode),
    );
  }
}
