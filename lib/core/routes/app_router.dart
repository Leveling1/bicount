import 'dart:async';

import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:bicount/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/company/domain/entities/company_model.dart';
import '../../features/company/presentation/screens/detail_company_screen.dart';
import '../../features/transaction/domain/entities/transaction_model.dart';
import '../../features/transaction/presentation/screens/detail_transaction_screen.dart';
import '../utils/custom_transition.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final GoRouter _router;

  AppRouter() : _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', builder: (context, state) => MainScreen()),
      GoRoute(path: '/company', builder: (context, state) => MainScreen()),
      GoRoute(path: '/transaction', builder: (context, state) => MainScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signUp', builder: (context, state) => SignUpScreen()),

      GoRoute(
        path: '/transactionDetail',
        pageBuilder: (context, state) {
          final transaction = state.extra as TransactionModel;
          return buildCustomTransitionPage(
            childContain: DetailTransactionScreen(transaction: transaction),
            state: state,
            model: TransactionModel,
          );
        },
      ),
      GoRoute(
        path: '/companyDetail',
        pageBuilder: (context, state) {
          final company = state.extra as CompanyModel;
          return buildCustomTransitionPage(
            childContain: DetailCompanyScreen(company: company),
            state: state,
            model: CompanyModel,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      final isLoggedIn = session != null;
      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/signUp';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  );

  GoRouter get router => _router;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners();
    });
  }
  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
