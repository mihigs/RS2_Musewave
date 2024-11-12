import 'package:admin_app/views/dashboards_page.dart';
import 'package:admin_app/views/genre_tracker_page.dart';
import 'package:admin_app/views/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/views/personal_page/personal_page.dart';
import 'package:admin_app/widgets/navigation_menu.dart';

class ContainerWithNavigation extends StatefulWidget {
  @override
  _ContainerWithNavigationState createState() =>
      _ContainerWithNavigationState();
}

class _ContainerWithNavigationState extends State<ContainerWithNavigation>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final _pageController = PageController();

  void onTabTapped(int index) {
    changePage(index);
  }

  void changePage(int index) {
    _pageController.jumpToPage(index);
  }

  List<Widget>? _children;

  @override
  void initState() {
    super.initState();
    _children ??= [
      DashboardsPage(),
      GenreTracker(),
      PersonalPage(),
      ReportsPage(),
      // Add more views here
    ];
  }

  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationMenu(
            selectedIndex: _selectedIndex,
            onTabTapped: onTabTapped,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _children!,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              physics:
                  const NeverScrollableScrollPhysics(), // Prevents swiping to switch tabs
            ),
          ),
        ],
      ),
    );
  }
}
