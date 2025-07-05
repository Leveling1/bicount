import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/authentification/presentation/screens/login_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/signup_screen.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  bool isAuthenticated(BuildContext context) =>
      context.read<AuthentificationBloc>().state
          is AuthentificationSuccess;

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
      if (!isAuthenticated(context) && !loggingIn) {
        return '/signUp';
      }
      if (isAuthenticated(context) && loggingIn) {
        return '/';
      }
      return null;
    },
  );
}
