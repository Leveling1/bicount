import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/features/main/presentation/widgets/app_bar_animation.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
import 'package:flutter/material.dart';

class MainShellBody extends StatelessWidget {
  const MainShellBody({
    super.key,
    required this.selectedIndex,
    required this.showSearchBar,
    required this.searchController,
    required this.selectedTransactionIndex,
    required this.onTransactionFilterTap,
    required this.pageController,
    required this.onPageChanged,
    required this.screens,
  });

  final int selectedIndex;
  final bool showSearchBar;
  final TextEditingController searchController;
  final int selectedTransactionIndex;
  final ValueChanged<int> onTransactionFilterTap;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final List<Widget> screens;

  @override
  Widget build(BuildContext context) {
    return ContainerBody(
      child: Column(
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
                        onChanged: (_) {},
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AppBarAnimation(
            child: selectedIndex == 2
                ? TransactionFilterChips(
                    selectedIndex: selectedTransactionIndex,
                    onTap: onTransactionFilterTap,
                    filters: TransactionTypes.allTypes,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}
