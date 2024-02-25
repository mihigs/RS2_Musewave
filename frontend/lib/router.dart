import 'package:flutter/material.dart';
import 'package:frontend/models/base/logged_in_state_info.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/login_page.dart';
import 'package:frontend/views/personal_page.dart';
import 'package:go_router/go_router.dart';


GoRouter routerGenerator(LoggedInStateInfo loggedInState) {
  return GoRouter(
    initialLocation: Routes.login,
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
        path: Routes.home,
        builder: (_, __) => HomePage(title: 'Musewave'),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, __) => PersonalPage(),
      ),
    ],
  );
}

abstract class Routes {
  static const home = '/home';
  static const signup = '/signup';
  static const login = '/login';
  static const profile = '/profile';
}