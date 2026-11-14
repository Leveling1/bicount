import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/features/main/presentation/widgets/app_bar_animation.dart';
import 'package:flutter/material.dart';

class MainShellBody extends StatelessWidget {
  const MainShellBody({
    super.key,
    required this.selectedIndex,
    required this.showSearchBar,
    required this.searchController,
    required this.pageController,
    required this.onPageChanged,
    required this.screens,
    this.lockHorizontalPaging = false,
    this.hasSharedContainer = false,
  });

  final int selectedIndex;
  final bool showSearchBar;
  final TextEditingController searchController;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final List<Widget> screens;
  final bool lockHorizontalPaging;
  final bool hasSharedContainer;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        AppBarAnimation(
          child: selectedIndex == 2
              ? SmoothInsert(
                  visible: showSearchBar,
                  verticalMargin: AppDimens.paddingSmall,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: CustomSearchField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: (_) {},
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            physics: lockHorizontalPaging
                ? const NeverScrollableScrollPhysics()
                : null,
            onPageChanged: onPageChanged,
            children: screens,
          ),
        ),
      ],
    );
    return hasSharedContainer ? content : ContainerBody(child: content);
  }
}
