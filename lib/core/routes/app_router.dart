import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  GoRouter get router => _routes;

  final _routes = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
		//TODO: add here reoutes
	]
	);
}