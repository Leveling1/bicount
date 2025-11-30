import 'dart:async';

import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/company/presentation/screens/detail_company_screen.dart';
import '../../features/group/domain/entities/group_model.dart';
import '../../features/group/presentation/screens/group_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/project/domain/entities/project_model.dart';
import '../../features/project/presentation/screens/project_screen.dart';
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
        path: '/companyDetail',
        pageBuilder: (context, state) {
          final cid = state.extra as String;
          return buildCustomTransitionPage(
            childContain: DetailCompanyScreen(cid: cid),
            state: state,
            model: String,
          );
        },
      ),

      GoRoute(
        path: '/project',
        pageBuilder: (context, state) {
          final projectData = state.extra as ProjectEntity;
          return buildCustomTransitionPage(
            childContain: ProjectScreen(projectData: projectData),
            state: state,
            model: ProjectEntity,
          );
        },
      ),

      GoRoute(
        path: '/group',
        pageBuilder: (context, state) {
          final groupData = state.extra as GroupEntity;
          return buildCustomTransitionPage(
            childContain: GroupScreen(groupData: groupData),
            state: state,
            model: GroupEntity,
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
