import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: const Icon(Icons.home),
          icon: const Icon(Icons.home_outlined),
          label: AppLocalizations.of(context)!.home,
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.search),
          icon: const Icon(Icons.search_outlined),
          label: AppLocalizations.of(context)!.search,
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.person),
          icon: const Icon(Icons.person_outlined),
          label: AppLocalizations.of(context)!.you,
        ),
      ],
      onDestinationSelected: widget.onTabTapped,
    );
  }
}
