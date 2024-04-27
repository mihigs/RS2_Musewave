import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:go_router/go_router.dart';

class NavigationMenu extends StatefulWidget {
  final int selectedIndex;
  final void Function(int index) onTabTapped;

  const NavigationMenu({Key? key, required this.selectedIndex, required this.onTabTapped}) : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.selectedIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.search),
          icon: Icon(Icons.search_outlined),
          label: 'Search',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person),
          icon: Icon(Icons.person_outlined),
          label: 'You',
        ),
      ],
      onDestinationSelected: widget.onTabTapped,
    );
  }
}
