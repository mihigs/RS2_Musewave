import 'dart:typed_data';

import 'package:admin_app/models/DTOs/admin_dashboard_details_dto.dart';
import 'package:admin_app/models/DTOs/reports_query.dart';
import 'package:admin_app/models/DTOs/similarity_matrix_dto.dart';
import 'package:admin_app/models/base/logged_in_state_info.dart';
import 'package:admin_app/models/report.dart';
import 'package:admin_app/services/base/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService extends ApiService {
  final FlutterSecureStorage secureStorage;
  final LoggedInStateInfo loggedInState = new LoggedInStateInfo();

  AdminService({required this.secureStorage}) : super(secureStorage: secureStorage);

  Future<AdminDashboardDetailsDto> GetDashboardDetails() async {
   AdminDashboardDetailsDto result;
    try {
      final response = await httpGet('Admin/GetDashboardDetails');
      result = AdminDashboardDetailsDto.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
    return result;

  }

  Future<SimilarityMatrixDto> GetSimilarityMatrix() async {
    SimilarityMatrixDto result;
    try {
      final response = await httpGet('Admin/GetSimilarityMatrix');
      result = SimilarityMatrixDto.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
    return result;
  }  

  Future<SimilarityMatrixDto> RefreshSimilarityMatrix() async {
    SimilarityMatrixDto result;
    try {
      final response = await httpGet('Admin/RefreshSimilarityMatrix');
      result = SimilarityMatrixDto.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
    return result;
  }

Future<List<Report>> GetReports(ReportsQuery query) async {
  final queryParams = query.toQueryParameters();

  try {
    final response = await httpGet("Admin/GetReports", queryParams: queryParams);

    List<dynamic> data = List<dynamic>.from(response['data']);

    // Convert each Map to a Report
    final List<Report> reports = List.empty(growable: true);
    for (var item in data) {
      reports.add(Report.fromJson(item));
    }
    return reports;
  } on Exception {
    rethrow;
  }
}

  Future<bool> GenerateReport({int? month, int? year}) async {
    try {
      final queryParams = <String>[];
      if (month != null) queryParams.add('?Month=$month&Year=$year');

      final response = await httpGet('Admin/GenerateReport', queryParams: queryParams);

      return true;
    } catch (e) {
      print('Exception in generateReport: $e');
      rethrow;
    }
  }

    Future<Uint8List> ExportReportAsPDF(int reportId) async {
    try {
      final queryParams = {'reportId': reportId.toString()};
      final response = await httpGetBytes('Admin/ExportReportAsPDF', queryParams: queryParams);

      return response; // This is the PDF data as Uint8List
    } catch (e) {
      print('Error in ExportReportAsPDF: $e');
      rethrow;
    }
  }

}
