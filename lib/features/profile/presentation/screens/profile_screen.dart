import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../core/widgets/user_card.dart';
import '../widgets/detail_friend.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/friend_card.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  final MainEntity data;
  const ProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileCard(
                  image: 'assets/memoji/memoji_1.png',
                  name: data.user.username,
                  email: data.user.email,
                  onTap: () {}
                ),
                //const SizedBox(height: 20),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: InfoCard(
                        icon: Icons.person,
                        title: 'Personnal',
                        value: data.user.profit!,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: InfoCard(
                        icon: Icons.person,
                        title: 'Personnal',
                        value: data.user.profit!,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: InfoCard(
                        icon: Icons.person,
                        title: 'Personnal',
                        value: data.user.profit!,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppDimens.marginMedium),
                    Flexible(
                      flex: 1,
                      child: InfoCard(
                        icon: Icons.person,
                        title: 'Personnal',
                        value: data.user.profit!,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: AppDimens.marginMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Friends",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: Theme.of(context).textButtonTheme.style,
                      child: Text(
                        "show more",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: data.friends.map((friend) {
                    return FriendCard(
                      friend: friend,
                      onTap: () {
                        showCustomBottomSheet(
                          context: context,
                          minHeight: 0.95,
                          color: null,
                          child: DetailFriend(
                            friend: friend,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
