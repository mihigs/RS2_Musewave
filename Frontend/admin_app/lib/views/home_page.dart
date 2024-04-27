import 'package:flutter/material.dart';
import 'package:admin_app/router.dart';
// import 'package:admin_app/models/DTOs/HomepageDetailsDto.dart';
// import 'package:admin_app/services/dashboard_service.dart';
import 'package:admin_app/widgets/navigation_menu.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.changePage});

  // final DashboardService dashboardService = GetIt.I<DashboardService>();

  final void Function(int index) changePage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late Future<HomepageDetailsDto> homepageDetails;

  @override
  void initState() {
    super.initState();
    // homepageDetails = widget.dashboardService.GetHomepageDetails();
  }

  Widget build(BuildContext context) {
    return Column();
  }
}
