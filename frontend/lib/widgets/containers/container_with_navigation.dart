import 'package:flutter/material.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/personal_page.dart';
import 'package:frontend/views/search_view.dart';
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
    _children = [
      HomePage(changePage: changePage),
      SearchPage(),
      PersonalPage(),
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
        physics: NeverScrollableScrollPhysics(), // Prevents swiping to switch tabs
      ),
      bottomNavigationBar: NavigationMenu(
        selectedIndex: _selectedIndex,
        onTabTapped: onTabTapped,
      ),
    );
  }
}



// class ContainerWithNavigation extends StatefulWidget {
//   final Widget child;

//   ContainerWithNavigation({super.key, required this.child});


//   final TracksService tracksService = GetIt.I<TracksService>();

//   @override
//   State<ContainerWithNavigation> createState() => _ContainerWithNavigationState();
// }

// class _ContainerWithNavigationState extends State<ContainerWithNavigation> {
//   get child => widget.child;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(child: child!),
//           ],
//         ),
//       bottomNavigationBar: const NavigationMenu(),
//     );
//   }
// }
