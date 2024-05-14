import 'package:flutter/material.dart';
import 'package:admin_app/models/base/logged_in_state_info.dart';
import 'package:admin_app/views/login_page.dart';
import 'package:admin_app/widgets/containers/navigation_container.dart';
import 'package:go_router/go_router.dart';

GoRouter routerGenerator(LoggedInStateInfo loggedInState) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: loggedInState,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnLogin = state.uri.toString() == Routes.login;
      final isOnSignUp = state.uri.toString() == Routes.signup;
      final isLoggedIn = loggedInState.isLoggedIn;

      if (!isOnLogin && !isOnSignUp && !isLoggedIn) return Routes.login;
      if ((isOnLogin || isOnSignUp) && isLoggedIn) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signup,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => ContainerWithNavigation(),
      ),
    ],
  );
}

abstract class Routes {
  static const signup = '/signup';
  static const login = '/login';
  static const home = '/';
  static const profile = '/profile';
}
