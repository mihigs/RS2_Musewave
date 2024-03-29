import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:frontend/widgets/shared/signalr_listener.dart';
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


// class NavigationMenu extends StatefulWidget {
//   const NavigationMenu({Key? key, required int selectedIndex, required void Function(int index) onTabTapped}) : super(key: key);

//   @override
//   _NavigationMenuState createState() => _NavigationMenuState();
// }

// class _NavigationMenuState extends State<NavigationMenu> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return NavigationBar(
//       selectedIndex: _selectedIndex,
//       destinations: const <Widget>[
//         NavigationDestination(
//           selectedIcon: Icon(Icons.home),
//           icon: Icon(Icons.home_outlined),
//           label: 'Home',
//         ),
//         NavigationDestination(
//           selectedIcon: Icon(Icons.search),
//           icon: Icon(Icons.search_outlined),
//           label: 'Search',
//         ),
//         NavigationDestination(
//           selectedIcon: Icon(Icons.person),
//           icon: Icon(Icons.person_outlined),
//           label: 'You',
//         ),
//       ],
//       onDestinationSelected: (int index) {
//         setState(() {
//           _selectedIndex = index;
//         });

//         // Respond to navigation item taps
//         if (index == 0) {
//           // Navigate to the home page
//           GoRouter.of(context).go(Routes.home);
//         } else if (index == 1) {
//           // Navigate to the search page
//           GoRouter.of(context).go(Routes.search);
//         } else if (index == 2) {
//           // Navigate to the user page
//           GoRouter.of(context).go(Routes.profile);
//         }
//       },
//     );
//   }
// }
