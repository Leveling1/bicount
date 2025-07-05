import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:bicount/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
