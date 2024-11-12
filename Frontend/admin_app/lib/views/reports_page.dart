import 'package:admin_app/models/DTOs/reports_query.dart';
import 'package:admin_app/widgets/create_a_report_modal.dart';
import 'package:admin_app/widgets/data_table_widget.dart';
import 'package:admin_app/widgets/report_filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_app/services/admin_service.dart';
import 'package:admin_app/models/report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<List<Report>> reportsFuture;
  bool _isLoading = false;

  ReportsQuery _currentQuery = ReportsQuery();
  bool _filtersApplied = false;

  Report? _selectedReport;

  @override
  void initState() {
    super.initState();
    reportsFuture = fetchReports();
  }

  Future<List<Report>> fetchReports() {
    return GetIt.I<AdminService>().GetReports(_currentQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<Report>>(
          future: reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return buildReportsTable(snapshot.data!);
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget buildReportsTable(List<Report> reports) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Text("Reports", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(width: 30),
              IconButton(
                icon: Icon(
                  Icons.filter_alt,
                  color: _filtersApplied ? Colors.blue : Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ReportFilterModal(
                        initialQuery: _currentQuery,
                        onFilterApplied: (ReportsQuery query) {
                          setState(() {
                            _currentQuery = query;
                            reportsFuture = fetchReports();
                            _filtersApplied = query.hasFilters();
                            _selectedReport = null;
                          });
                        },
                      );
                    },
                  );
                },
              ),
              Spacer(),
              if (_selectedReport != null)
                ElevatedButton.icon(
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text("Export as PDF"),
                  onPressed: _exportReportAsPDF,
                ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Create a report"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateAReportModal(
                        onReportCreated: () {
                          setState(() {
                            reportsFuture = fetchReports();
                            _selectedReport = null;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTableWidget(
              reports: reports,
              onReportSelected: (Report? report) {
                setState(() {
                  _selectedReport = report;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _exportReportAsPDF() async {
    if (_selectedReport == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pdfData = await GetIt.I<AdminService>().ExportReportAsPDF(_selectedReport!.id);

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Define the file path
      final fileName = 'Report_${_selectedReport!.reportYear}_${_selectedReport!.reportMonth}.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save the PDF file
      final file = File(filePath);
      await file.writeAsBytes(pdfData);

      // Open the PDF file
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error exporting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
