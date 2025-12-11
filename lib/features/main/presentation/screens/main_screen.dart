import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/services/title_animated_switcher.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/main/presentation/widgets/app_bar_animation.dart';
import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/custom_search_field.dart';
import 'package:bicount/core/widgets/header_button.dart';
import 'package:bicount/features/company/presentation/screens/company_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:bicount/features/profile/presentation/screens/account_funding_handler.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/network_status.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../company/presentation/screens/company_handler.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transaction/presentation/screens/transaction_handler.dart';
import '../../domain/entities/main_entity.dart';
import '../bloc/main_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<MainEntity> startData;
  PageController pageController = PageController();
  ValueNotifier<double> scrollXPosition = ValueNotifier(0.0);
  bool showSearchBar = false;

  int _selectedIndex = 0;

  final searchCompany = TextEditingController();
  final searchTransaction = TextEditingController();
  int _selectedIndexTransaction = 0;

  void _onItemTappedTransaction(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedIndexTransaction = index;
      });
    });
  }

  void _onItemTapped(int index) {
    final distance = (_selectedIndex - index).abs();
    Duration duration = const Duration(milliseconds: 500);

    if (distance == 1) {
      pageController.animateToPage(
        index,
        duration: duration,
        curve: Curves.linear,
      );
    } else {
      pageController.jumpToPage(index);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToPage(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onItemTapped(index);
    });
  }

  List<Widget> _buildScreens(MainEntity data) {
    if (data.transactions.isNotEmpty && data.transactions.length > 1) {
      data.transactions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }

    return [
      HomeScreen(onCardTap: _goToPage, data: data),
      CompanyScreen(
        showSearchBar: showSearchBar,
        searchController: searchCompany,
      ),
      TransactionScreen(
        data: data,
        showSearchBar: showSearchBar,
        searchController: searchTransaction,
        selectedIndexTransaction: _selectedIndexTransaction,
      ),
      ProfileScreen(data: data),
    ];
  }

  List<String> _buildTitle() {
    return ['', 'Company', 'Transaction', 'Profile'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle deep link navigation
    final location = GoRouter.of(context).state.uri.toString();
    if (location == '/company') {
      _goToPage(1);
    } else if (location == '/transaction') {
      _goToPage(2);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainBloc>().add(GetAllStartData());
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    scrollXPosition.dispose();
    searchCompany.dispose();
    searchTransaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if (state is MainStateConnexion) {
          if (state.networkStatus == NetworkStatus.disconnected) {
            NotificationHelper.showFailureNotification(
              context,
              "Internet connection lost: you are in offline mode",
            );
          } else if (state.networkStatus == NetworkStatus.unstable) {
            NotificationHelper.showFailureNotification(
              context,
              "Unstable internet connection",
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).bottomNavigationBarTheme.backgroundColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: TitleAnimatedSwitcher(
              child: Text(
                _buildTitle()[_selectedIndex],
                key: ValueKey(_selectedIndex),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            actions: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: (_selectedIndex == 1 || _selectedIndex == 2)
                    ? IconButton(
                        key: ValueKey('search_$_selectedIndex$showSearchBar'),
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: !showSearchBar
                              ? Icon(
                                  Icons.search,
                                  key: const ValueKey('icon_search'),
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.color!,
                                  size: AppDimens.iconSizeMedium,
                                )
                              : Icon(
                                  Icons.close,
                                  key: const ValueKey('icon_close'),
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.color!,
                                  size: AppDimens.iconSizeMedium,
                                ),
                        ),
                      )
                    : (_selectedIndex == 3)
                    ? Row(
                        key: ValueKey('profile_actions_$_selectedIndex'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HeaderButton(
                            text: 'Add funds',
                            icon: Icons.add,
                            onTap: () {
                              showCustomBottomSheet(
                                context: context,
                                minHeight: 0.95,
                                color: null,
                                child: AccountFundingHandler(),
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('no_action')),
              ),
            ],
          ),
          body: ContainerBody(
            child: Column(
              children: [
                AppBarAnimation(
                  child: (_selectedIndex == 1 || _selectedIndex == 2)
                      ? SmoothInsert(
                          visible: showSearchBar,
                          verticalMargin: AppDimens.paddingSmall,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingMedium,
                            ),
                            child: CustomSearchField(
                              controller: (_selectedIndex == 1)
                                  ? searchCompany
                                  : searchTransaction,
                              onChanged: (value) {},
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                AppBarAnimation(
                  child: (_selectedIndex == 2)
                      ? TransactionFilterChips(
                          selectedIndex: _selectedIndexTransaction,
                          onTap: _onItemTappedTransaction,
                          filters: TransactionTypes.allTypes,
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: _buildScreens(
                      state is MainLoaded
                          ? state.startData
                          : MainEntity.fromEmpty(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          floatingActionButton: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _selectedIndex != 0 && _selectedIndex != 3
                ? FloatingActionButton(
                    key: const ValueKey('fab'),
                    onPressed: () {
                      showCustomBottomSheet(
                        context: context,
                        minHeight: _selectedIndex == 1 ? 0.5 : 0.95,
                        color: null,
                        child: _selectedIndex == 1
                            ? const CompanyHandler()
                            : TransactionHandler(
                                user: state is MainLoaded
                                    ? state.startData.user
                                    : null,
                                friends: state is MainLoaded
                                    ? state.startData.friends
                                    : [],
                              ),
                      );
                    },
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('sizedBox')),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
