import 'dart:convert';
import 'package:admin_app/models/DTOs/admin_dashboard_details_dto.dart';
import 'package:admin_app/models/DTOs/similarity_matrix_dto.dart';
import 'package:admin_app/models/base/logged_in_state_info.dart';
import 'package:admin_app/models/user.dart';
import 'package:admin_app/services/base/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:admin_app/services/signalr_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

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

  Future<SimilarityMatrixDto> UpdateSimilarityMatrix() async {
    SimilarityMatrixDto result;
    try {
      final response = await httpGet('Admin/UpdateSimilarityMatrix');
      result = SimilarityMatrixDto.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
    return result;
  }

}
