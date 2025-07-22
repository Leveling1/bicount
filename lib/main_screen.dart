import 'package:bicount/core/widgets/container_body.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/features/company/presentation/screens/company_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController pageController = PageController();
  ValueNotifier<double> scrollXPosition = ValueNotifier(0.0);
  int _selectedIndex = 0;

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

  List<Widget> _buildScreens() {
    return [
      HomeScreen(onCardTap: _goToPage),
      CompanyScreen(),
      TransactionScreen(),
    ];
  }

  List<String> _buildTitle() {
    return ['', 'Company', 'Transaction'];
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
  Widget build(BuildContext context) {
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _buildTitle()[_selectedIndex],
            key: ValueKey(_selectedIndex),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      body: ContainerBody(
        child: PageView(
          controller: pageController,
          onPageChanged: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _buildScreens(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
