import 'package:flutter/material.dart';
import 'package:admin_app/router.dart';
import 'package:go_router/go_router.dart';

class NavigationMenu extends StatefulWidget {
  final int selectedIndex;
  final void Function(int index) onTabTapped;

  const NavigationMenu(
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
          Container(
            width: 60,
            decoration: widget.selectedIndex == 0
                ? const BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(Radius.circular(20)))
                : null,
            child: IconButton(
              icon: Icon(Icons.home_rounded),
              color: widget.selectedIndex == 0 ? Colors.white : Colors.grey,
              onPressed: () => widget.onTabTapped(0),
              hoverColor: Colors.white10,
            ),
          ),
          SizedBox(height: 20),
          Container(
              width: 60,
              decoration: widget.selectedIndex == 1
                  ? const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : null,
              child: IconButton(
                icon: Icon(Icons.dashboard_rounded),
                color: widget.selectedIndex == 1 ? Colors.white : Colors.grey,
                // onPressed: () => widget.onTabTapped(1),
                onPressed: () => null,
                hoverColor: Colors.white10,
              )),
          SizedBox(height: 20),
          Container(
              width: 60,
              decoration: widget.selectedIndex == 2
                  ? const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(Radius.circular(20)))
                  : null,
              child: IconButton(
                icon: Icon(Icons.person),
                color: widget.selectedIndex == 2 ? Colors.white : Colors.grey,
                onPressed: () => widget.onTabTapped(2),
                hoverColor: Colors.white10,
              )),
        ],
      ),
    );
  }
}
