import 'package:admin_app/models/DTOs/admin_dashboard_details_dto.dart';
import 'package:admin_app/services/admin_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DashboardsPage extends StatefulWidget {
  DashboardsPage({super.key});

  @override
  State<DashboardsPage> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends State<DashboardsPage> {
  late Future<AdminDashboardDetailsDto> dashboardDetails;

  @override
  void initState() {
    super.initState();
    dashboardDetails = GetIt.I<AdminService>().GetDashboardDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminDashboardDetailsDto>(
      future: dashboardDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return buildDashboard(snapshot.data!);
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildDashboard(AdminDashboardDetailsDto data) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 25, top: 10),
                child: Row(
                  children: [
                    Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                )
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        GeneralCard(data: data),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        UsersCard(data: data),
                      ],
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth * 0.01),
                  Expanded(
                    child: RightSideCard(data: data),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneralCard extends StatelessWidget {
  final AdminDashboardDetailsDto data;

  const GeneralCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(15),
        child: ListTile(
          title: Text('General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                DashboardItem(title: 'Songs available', value: '${data.musewaveTrackCount + data.jamendoTrackCount}'),
                DashboardItem(title: 'Minutes listened:', value: '${(data.totalTimeListened / 60).toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UsersCard extends StatelessWidget {
  final AdminDashboardDetailsDto data;

  const UsersCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(15),
        child: ListTile(
          title: Text('Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                DashboardItem(title: 'Daily logins:', value: '${data.dailyLoginCount}'),
                DashboardItem(title: 'Artists:', value: '${data.artistCount}'),
                DashboardItem(title: 'Users:', value: '${data.userCount}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RightSideCard extends StatelessWidget {
  final AdminDashboardDetailsDto data;

  const RightSideCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(15),
        child: ListTile(
          title: Text('Jamendo API Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .49,
                child: ListTile(
                  title: Text('Tracks'),
                  subtitle: PieChartWidget(
                    musewaveTrackCount: data.musewaveTrackCount,
                    jamendoTrackCount: data.jamendoTrackCount,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * .19,
                child: ListTile(
                  title: Text('Jamendo API Usage'),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: data.jamendoApiActivity / 50000,
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        Container(
                          child: Text(
                            "${data.jamendoApiActivity} / 50000"
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class PieChartWidget extends StatelessWidget {
  final int musewaveTrackCount;
  final int jamendoTrackCount;

  PieChartWidget({Key? key, required this.musewaveTrackCount, required this.jamendoTrackCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: musewaveTrackCount.toDouble(),
            title: 'Musewave',
            color: Colors.deepOrangeAccent,
            radius: 50,
          ),
          PieChartSectionData(
            value: jamendoTrackCount.toDouble(),
            title: 'Jamendo',
            color: Colors.blueGrey,
            radius: 50,
          ),
        ],
        sectionsSpace: 2, // Defines the space between the sections
        centerSpaceRadius: 48, // Defines the radius of the center space (hole)
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final String value;

  const DashboardItem({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.grey)),
          Text(value, style: Theme.of(context).textTheme.bodyText2),
        ],
      ),
    );
  }
}


// Continue with the rest of the widgets (DashboardItem, etc.) from the previous code snippet.


// import 'package:admin_app/models/DTOs/admin_dashboard_details_dto.dart';
// import 'package:admin_app/services/admin_service.dart';
// import 'package:flutter/material.dart';
// import 'package:admin_app/router.dart';
// import 'package:admin_app/widgets/navigation_menu.dart';
// import 'package:get_it/get_it.dart';
// import 'package:go_router/go_router.dart';

// class DashboardsPage extends StatefulWidget {
//   DashboardsPage({super.key});

//   @override
//   State<DashboardsPage> createState() => _DashboardsPageState();
// }

// class _DashboardsPageState extends State<DashboardsPage> {
//   late Future<AdminDashboardDetailsDto> dashboardDetails;

//   @override
//   void initState() {
//     super.initState();
//     dashboardDetails = GetIt.I<AdminService>().GetDashboardDetails();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<AdminDashboardDetailsDto>(
//       future: dashboardDetails,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else if (snapshot.hasData) {
//             return buildDashboard(snapshot.data!);
//           }
//         }
//         return CircularProgressIndicator();
//       },
//     );
//   }

//   Widget buildDashboard(AdminDashboardDetailsDto data) {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           DashboardSection(title: 'General', children: [
//             DashboardItem(title: 'Songs available', value: '${data.musewaveTrackCount + data.jamendoTrackCount}'),
//             DashboardItem(title: 'Minutes listened:', value: '${data.totalTimeListened / 60}'),
//           ]),
//           DashboardSection(title: 'Users', children: [
//             DashboardItem(title: 'Daily logins:', value: '${data.dailyLoginCount}'),
//             DashboardItem(title: 'Artists:', value: '${data.artistCount}'),
//             DashboardItem(title: 'Users:', value: '${data.userCount}'),
//           ]),
//           DashboardSection(title: 'Tracks', children: [
//             // You can add the PieChart here
//           ]),
//           DashboardSection(title: 'Jamendo API Usage', children: [
//             // You can use a LinearProgressIndicator for the API usage bar
//             LinearProgressIndicator(value: data.jamendoApiActivity / 50000),
//           ]),
//         ],
//       ),
//     );
//   }
// }

// class DashboardSection extends StatelessWidget {
//   final String title;
//   final List<Widget> children;

//   const DashboardSection({Key? key, required this.title, required this.children}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Card(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               ...children,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DashboardItem extends StatelessWidget {
//   final String title;
//   final String value;

//   const DashboardItem({Key? key, required this.title, required this.value}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title),
//         Text(value),
//       ],
//     );
//   }
// }
