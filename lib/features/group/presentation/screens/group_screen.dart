import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_dimens.dart';
import '../../../../core/utils/expandable_text.dart';
import '../../../../core/utils/memoji_utils.dart';
import '../../../../core/widgets/circle_image_skeleton.dart';
import '../../../../core/widgets/user_card.dart';
import '../../domain/entities/group_model.dart';
import '../../domain/entities/member_model.dart';
import '../bloc/group_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/grid_view_skeleton.dart';

class GroupScreen extends StatefulWidget {
  final GroupModel groupData;
  const GroupScreen({super.key, required this.groupData});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {

  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(GetAllGroupDetails(widget.groupData));
  }

  @override
  Widget build(BuildContext context) {
    final width = 120.0;
    final height = 120.0;
    final radius = 40.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Group info',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.titleSmall!.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add,
              color: Theme.of(context).textTheme.titleSmall!.color,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).textTheme.titleSmall!.color,
              size: 20,
            ),
          ),
        ],
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge,),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                        radius: radius,
                        child: ClipOval(
                          child: widget.groupData.image != null && widget.groupData.image != ""
                          ? CachedNetworkImage(
                            imageUrl: widget.groupData.image!,
                            width: width.w,
                            height: height.h,
                            placeholder: (context, url) => CircleImageSkeleton(
                                width: width.w,
                                height: height.h
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ) : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.people,
                              size: width,
                              color: AppColors.inactiveColorDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupData.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              '${widget.groupData.number} members',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 5,),
                            widget.groupData.description != null && widget.groupData.description != ""
                            ? ExpandableText(
                              widget.groupData.description!,
                            ) : const SizedBox.shrink(),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15,),
                  state is GroupDetailsLoading
                  ? const MembersSkeleton()
                  : state is GroupDetailsLoaded
                    ? state.members.isNotEmpty
                      ? GridView.builder(
                      itemCount: state.members.length,
                        shrinkWrap: true, // Important pour une GridView dans une SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Pour éviter le scroll interne
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Nombre de colonnes
                          crossAxisSpacing: 10.0, // Espace horizontal entre les cartes
                          mainAxisSpacing: 10.0, // Espace vertical entre les cartes
                          childAspectRatio: 3 / 3, // Ratio largeur/hauteur pour chaque carte
                        ),
                        itemBuilder: (context, index) {
                          final member = state.members[index];
                          return UserCard(user: member);
                        },
                      )
                      : Center(child: const Text("No members"))
                    : const MembersSkeleton(),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}