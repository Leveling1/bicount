import 'dart:developer';
import 'package:flutter/material.dart';

class MyNavigationObserver implements NavigatorObserver {
  NavigatorState? navigatorState;
  MyNavigationObserver({required this.navigatorState});

  @override
  void didPop(Route route, Route? previousRoute) {
    log('didPop: ${route.settings.name}');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    log('didPush: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    log('didRemove: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    log('didReplace: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    log('didStartUserGesture: ${route.settings.name}');
  }

  @override
  void didStopUserGesture() {
    log('didStopUserGesture');
  }

  @override
  NavigatorState? get navigator => navigatorState;
  
  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
  }
}
