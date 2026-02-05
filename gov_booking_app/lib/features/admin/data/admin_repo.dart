import 'package:dio/dio.dart';
import '../../Citizen/models/office_model.dart';
import '../../Citizen/models/service_model.dart';
import '../../auth/models/user_model.dart';
import '../../../core/api/api_endpoints.dart';


class AdminRepo {
  final Dio _dio;
  AdminRepo(this._dio);

  String _path(String endpoint) {
    if (endpoint.startsWith('/api/')) {
      return endpoint.substring(4);
    }
    return endpoint;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get(_path(ApiEndpoints.adminStats));
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getSummaryReport() async {
    final response = await _dio.get(_path(ApiEndpoints.adminReportsSummary));
    return response.data['data'];
  }

  // Office Management
  Future<List<Office>> getAllOffices() async {
    final response = await _dio.get(_path(ApiEndpoints.adminOffices));
    return (response.data['data'] as List).map((e) => Office.fromJson(e)).toList();
  }

  Future<void> createOffice(Map<String, dynamic> data) async {
    await _dio.post(_path(ApiEndpoints.adminOffices), data: data);
  }

  Future<void> updateOffice(String id, Map<String, dynamic> data) async {
    await _dio.patch(_path(ApiEndpoints.adminOfficeById(id)), data: data);
  }

  Future<void> toggleOffice(String id) async {
    await _dio.patch(_path(ApiEndpoints.adminOfficeToggleActive(id)));
  }

  Future<void> generateSlots(String officeId) async {
    await _dio.post(_path(ApiEndpoints.adminGenerateSlots(officeId)));
  }

  // Service Management
  Future<List<GovernmentService>> getAllServices({String? officeId}) async {
    final response = await _dio.get(
      _path(ApiEndpoints.adminServices),
      queryParameters: officeId == null ? null : {'officeId': officeId},
    );
    return (response.data['data'] as List).map((e) => GovernmentService.fromJson(e)).toList();
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await _dio.post(_path(ApiEndpoints.adminServices), data: data);
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _dio.patch(_path(ApiEndpoints.adminServiceById(id)), data: data);
  }

  Future<void> toggleService(String id) async {
    await _dio.patch(_path(ApiEndpoints.adminServiceToggleActive(id)));
  }

  // Booking Queue
  Future<List<Map<String, dynamic>>> getAllBookings({String? status}) async {
    final response = await _dio.get(
      _path(ApiEndpoints.adminBookings),
      queryParameters: status == null ? null : {'status': status},
    );
    return (response.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> approveBooking(String bookingId) async {
    await _dio.put(_path(ApiEndpoints.adminApproveBooking(bookingId)));
  }

  Future<void> rejectBooking(String bookingId, String reason) async {
    await _dio.put(_path(ApiEndpoints.adminRejectBooking(bookingId)), data: {'reason': reason});
  }

  Future<void> completeBooking(String bookingId) async {
    await _dio.put(_path(ApiEndpoints.adminCompleteBooking(bookingId)));
  }

  // User Management
  Future<List<UserModel>> getAllUsers({String? role}) async {
    final response = await _dio.get(_path(ApiEndpoints.adminUsers), queryParameters: role != null ? {'role': role} : null);
    return (response.data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _dio.post(_path(ApiEndpoints.adminUsers), data: data);
  }

  Future<void> toggleUserActive(String id) async {
    await _dio.patch(_path(ApiEndpoints.adminToggleUserActive(id)));
  }
}
