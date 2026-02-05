import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/booking_models.dart';

class CitizenRepo {
  final Dio _dio;
  CitizenRepo(this._dio);

  Future<List<Office>> getOffices() async {
    try {
      final res = await _dio.get(ApiEndpoints.offices);
      final list = (res.data["data"] as List? ?? []);
      return list.map((e) => Office.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GovernmentService>> getServicesForOffice(String officeId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.services,
        queryParameters: {"officeId": officeId},
      );
      final list = (res.data["data"] as List? ?? []);
      return list.map((e) => GovernmentService.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimeSlot>> getSlots({
    required String officeId,
    required String date, // YYYY-MM-DD
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.officeSlots(officeId),
        queryParameters: {"date": date},
      );
      final list = (res.data["data"] as List? ?? []);
      return list.map((e) => TimeSlot.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> createBooking({
    required String officeId,
    required String serviceId,
    required String timeSlotId,
    required String date, // YYYY-MM-DD
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.bookings, data: {
        "officeId": officeId,
        "serviceId": serviceId,
        "timeSlotId": timeSlotId,
        "date": date,
      });

      final data = res.data["data"] as Map<String, dynamic>;
      return Booking.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Booking>> myBookings() async {
    try {
      final res = await _dio.get(ApiEndpoints.myBookings);
      final list = (res.data["data"] as List? ?? []);
      return list.map((e) => Booking.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

