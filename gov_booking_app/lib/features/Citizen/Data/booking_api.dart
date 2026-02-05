
import '../../../core/dio_client.dart';

class BookingApi {
  Future<Map<String, dynamic>> createBooking({
    required String officeId,
    required String serviceId,
    required String timeSlotId,
    required String date, // "2026-02-02"
    String notes = "",
  }) async {
    final res = await DioClient.dio.post("/bookings", data: {
      "officeId": officeId,
      "serviceId": serviceId,
      "timeSlotId": timeSlotId,
      "date": date,
      "notes": notes,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> myBookings() async {
    final res = await DioClient.dio.get("/bookings/my");
    return res.data;
  }
}
