import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/friend/presentation/screens/friend_screen.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void openInviteHub(BuildContext context) {
  final state = context.read<MainBloc>().state;
  if (state is! MainLoaded) {
    return;
  }

  showCustomBottomSheet(
    context: context,
    minHeight: 0.6,
    child: FriendScreen(
      user: state.startData.user,
      friends: state.startData.friends,
    ),
  );
}
