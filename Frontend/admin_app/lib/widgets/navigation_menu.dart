import 'package:admin_app/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/router.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class NavigationMenu extends StatefulWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();
  final int selectedIndex;
  final void Function(int index) onTabTapped;

  NavigationMenu(
      {Key? key, required this.selectedIndex, required this.onTabTapped})
      : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      width: 80,
      color: Colors.black38,
      child: Column(
        children: [
          SizedBox(height: 20),
          Container(
              width: 60,
              decoration: widget.selectedIndex == 0
                  ? const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : null,
              child: IconButton(
                icon: Icon(Icons.dashboard_rounded),
                color: widget.selectedIndex == 0 ? Colors.white : Colors.grey,
                onPressed: () => widget.onTabTapped(0),
                hoverColor: Colors.white10,
              )),
          SizedBox(height: 20),
          Container(
              width: 60,
              decoration: widget.selectedIndex == 1
                  ? const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : null,
              child: IconButton(
                icon: Icon(Icons.category),
                color: widget.selectedIndex == 1 ? Colors.white : Colors.grey,
                onPressed: () => widget.onTabTapped(1),
                hoverColor: Colors.white10,
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.8),
          Container(
              width: 60,
              decoration: widget.selectedIndex == 2
                  ? const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : null,
              child: IconButton(
                icon: Icon(Icons.logout),
                color: widget.selectedIndex == 2 ? Colors.white : Colors.grey,
                onPressed: () async => await widget.authService.logout(),
                hoverColor: Colors.white10,
              )),
        ],
      ),
    );
  }
}
