import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:go_router/go_router.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'You',
          selectedIcon: Icon(Icons.person),
        ),
      ],
      onDestinationSelected: (int index) {
        // Respond to navigation item taps
        if (index == 0) {
          // Navigate to the home page
          GoRouter.of(context).go(Routes.home);
        } else if (index == 1) {
          // Navigate to the search page
        } else if (index == 2) {
          // Navigate to the user page
          GoRouter.of(context).go(Routes.profile);
        }
      },
    );
  }
}
