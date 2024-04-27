import 'package:flutter/material.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/personal_page/personal_page.dart';
import 'package:frontend/views/search_view.dart';
import 'package:frontend/widgets/containers/persistent_player_container.dart';
import 'package:frontend/widgets/navigation_menu.dart';

class ContainerWithNavigation extends StatefulWidget {
  @override
  _ContainerWithNavigationState createState() => _ContainerWithNavigationState();
}

class _ContainerWithNavigationState extends State<ContainerWithNavigation>  with AutomaticKeepAliveClientMixin  {
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
        PersistentPlayerContainer(child: HomePage(changePage: changePage)),
        PersistentPlayerContainer(child: SearchPage()),
        PersistentPlayerContainer(child: PersonalPage()),
        // Add more views here
      ];
  }
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _children!,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Prevents swiping to switch tabs
      ),
      bottomNavigationBar: NavigationMenu(
        selectedIndex: _selectedIndex,
        onTabTapped: onTabTapped,
      ),
    );
  }
}
