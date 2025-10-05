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
  final ScrollController _scrollController = ScrollController();
  bool _isAtAppBar = false;

  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 130.0;


  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(GetAllGroupDetails(widget.groupData));

    // Écouter les changements de position de défilement
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Déclencher un rebuild lorsque la position change
    setState(() {
      // Si le défilement est supérieur à 100 pixels, on considère qu'on a atteint l'AppBar
      _isAtAppBar = _scrollController.offset > 130;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Group info',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        backgroundColor: _isAtAppBar
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // Cette callback est appelée à chaque défilement
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. En-tête flexible
                SliverAppBar(
                  expandedHeight: _headerHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeaderContent(),
                  ),
                  pinned: false,
                  snap: false,
                  floating: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                ),

                // 2. Contenu principal avec couleur dynamique
                SliverToBoxAdapter(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height - _headerHeight,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor, // Couleur normale
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppDimens.borderRadiusLarge),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.paddingLarge),
                      child: state is GroupDetailsLoading
                          ? const MembersSkeleton()
                          : state is GroupDetailsLoaded
                          ? _buildMembersGrid(state.members)
                          : const MembersSkeleton(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Méthode pour construire l'en-tête (identique à précédemment)
  Widget _buildHeaderContent() {
    final width = 120.0;
    final height = 120.0;
    final radius = 40.0;

    return Container(
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    width: width.w, height: height.h),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.people,
                  size: width,
                  color: AppColors.inactiveColorDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 5),
                widget.groupData.description != null && widget.groupData.description != ""
                    ? ExpandableText(
                      "${widget.groupData.description!} fuhzoiufzuhfuzfhiuzhfiuzhfuzhfiuhfuzhfui zifizhfuzhfzhiuf zfu hzifzhf zhf zhfzh fzhf zhfizhf zfizhfiuzfhiuzfh iuzfzhfiuzh iuzhfzh fzhfizhfiuzhfiuzhf ziuzhfuzfu hziuf hziufhz iuzuf zfzifh ziuf hzfzh fiuzfhuzhf uzfh izfiuz fizfi zhfuizhfiuzfhiuz fizhfiuhiufhuifheui fizuhfzifhiuz",
                      onHeightChanged: (newHeight, isExpanded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            if (isExpanded) {
                              setState(() {
                                _headerHeight = 80.h + newHeight;
                              });
                            } else {
                              setState(() {
                                _headerHeight = 130;
                              });
                            }
                          }
                        });
                      },
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Méthode pour construire la grille des membres
  Widget _buildMembersGrid(List<MemberModel> members) {
    if (members.isEmpty) return Center(child: const Text("No members yet."));

    return GridView.builder(
      itemCount: members.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 3 / 3,
      ),
      itemBuilder: (context, index) {
        final member = members[index];
        return UserCard(user: member);
      },
    );
  }
}