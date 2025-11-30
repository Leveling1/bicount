import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../widgets/detail_friend.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/friend_card.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  final MainEntity data;
  const ProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<FriendsModel> friends = data.friends;
    friends.sort(
      (a, b) => ((b.give ?? 0) - (b.receive ?? 0)).compareTo(
        (a.give ?? 0) - (a.receive ?? 0),
      ),
    );
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: Column(
                children: [
                  ProfileCard(
                    image: data.user.image,
                    name: data.user.username,
                    email: data.user.email,
                    onTap: () {},
                  ),
                  //const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: InfoCard(
                          icon: Icons.person,
                          title: 'Profit',
                          value: data.user.profit!,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: AppDimens.marginMedium),
                      Flexible(
                        flex: 1,
                        child: InfoCard(
                          icon: Icons.person,
                          title: 'Expense',
                          value: data.user.expenses!,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: InfoCard(
                          icon: Icons.person,
                          title: 'Personal',
                          value: data.user.personalIncome!,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: AppDimens.marginMedium),
                      Flexible(
                        flex: 1,
                        child: InfoCard(
                          icon: Icons.person,
                          title: 'Company',
                          value: data.user.companyIncome!,
                          color: Colors.blue,
                        ),
                      ),
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
                    children: friends.take(3).map((friend) {
                      if (friend.uid == data.user.uid) {
                        return const SizedBox.shrink();
                      }
                      return FriendCard(
                        friend: friend,
                        onTap: () {
                          showCustomBottomSheet(
                            context: context,
                            minHeight: 0.70,
                            color: null,
                            child: DetailFriend(friend: friend),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
