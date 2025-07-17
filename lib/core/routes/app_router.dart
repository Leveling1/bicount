import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:bicount/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/transaction/domain/entities/transaction_model.dart';
import '../../features/transaction/presentation/screens/detail_transaction_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  GoRouter get router => _routes;

  late final _routes = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', builder: (context, state) => MainScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/signUp',
        builder: (context, state) {
          return SignUpScreen();
        },
      ),
      GoRoute(
        path: '/transactionDetail',
        pageBuilder: (context, state) {
          final transaction = state.extra as TransactionModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: DetailTransactionScreen(transaction: transaction),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Slide from right → left
              final tween = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    ],
    redirect: (context, state) {
      final currentPath = state.uri.toString();
      final loggingIn = currentPath == '/login' || currentPath == '/signUp';
      if (!isAuthenticated && !loggingIn) {
        return '/signUp';
      }
      if (isAuthenticated && loggingIn) {
        return '/';
      }
      return null;
    },
  );
}
