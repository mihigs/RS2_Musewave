import 'package:flutter/material.dart';
import 'package:frontend/models/base/logged_in_state_info.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/login_page.dart';
import 'package:frontend/views/personal_page.dart';
import 'package:frontend/views/search_view.dart';
import 'package:frontend/widgets/containers/container_with_navigation.dart';
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
        path: Routes.home,
        builder: (_, __) => ContainerWithNavigation(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (_, __) => ContainerWithNavigation(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, __) => ContainerWithNavigation(),
      ),
    ],
  );
}

abstract class Routes {
  static const signup = '/signup';
  static const login = '/login';
  static const home = '/home';
  static const search = '/search';
  static const profile = '/profile';
}