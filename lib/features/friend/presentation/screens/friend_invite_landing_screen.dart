import 'package:bicount/features/friend/presentation/screens/friend_screen.dart';
import 'package:flutter/material.dart';

class FriendInviteLandingScreen extends StatelessWidget {
  const FriendInviteLandingScreen({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Friend invite')),
      body: FriendScreen(initialInviteCode: inviteCode),
    );
  }
}
