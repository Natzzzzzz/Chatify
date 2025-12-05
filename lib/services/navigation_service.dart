import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void removeAndNavigateToRoute(String _route) {
    navigatorKey.currentState?.popAndPushNamed(_route);
  }

  void navigateToRout(String _route) {
    navigatorKey.currentState?.pushNamed(_route);
  }

  Future<T?> navigateToPage<T>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void navigateToRoute(Route route) {
    navigatorKey.currentState?.push(route);
  }

  void goBack<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }
}
