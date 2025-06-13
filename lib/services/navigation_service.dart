import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void removeAndNavigateToRoute(String _route) {
    navigatorKey.currentState?.popAndPushNamed(_route);
  }

  void navigateToRout(String _route) {
    navigatorKey.currentState?.pushNamed(_route);
  }

  void navigateToPage(Widget _page) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return _page;
        },
      ),
    );
  }

  void goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
