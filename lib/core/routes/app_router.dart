import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // Replace this with your actual authentication logic
  bool get isAuthenticated =>
      false; // TODO: connect to AuthentificationBloc or Provider

  GoRouter get router => _routes;

  late final _routes = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
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
