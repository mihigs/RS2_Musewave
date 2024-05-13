import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/HomepageDetailsDto.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/widgets/for_you_results.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.changePage});

  final DashboardService dashboardService = GetIt.I<DashboardService>();

  final void Function(int index) changePage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomepageDetailsDto> homepageDetails;

  @override
  void initState() {
    super.initState();
    homepageDetails = widget.dashboardService.GetHomepageDetails();
  }

  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(10, 35, 10, 10),
            child: GestureDetector(
              child: AbsorbPointer(
                absorbing: true,
                child: SearchBarWidget(
                  key: null,
                ),
              ),
              onTap: () {
                // Navigate to search
                widget.changePage(1);
              },
            ),
          ),
          Expanded(child: ForYouResults(
            homepageDetails: homepageDetails,
          )),
        ],
      );
  }
}
