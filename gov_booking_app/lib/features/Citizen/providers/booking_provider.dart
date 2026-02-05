import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:gov_booking_app/core/network/dio_client.dart';

import 'package:gov_booking_app/features/Citizen/models/booking_models.dart';



final citizenBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get(ApiEndpoints.myBookings);
  return (response.data['data'] as List).map((e) => Booking.fromJson(e)).toList();
});

final officesProvider = FutureProvider<List<Office>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get(ApiEndpoints.offices);
  return (response.data['data'] as List).map((e) => Office.fromJson(e)).toList();
});

final servicesProvider = FutureProvider.family<List<GovernmentService>, String>((ref, officeId) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('${ApiEndpoints.offices}/$officeId/services');
  return (response.data['data'] as List).map((e) => GovernmentService.fromJson(e)).toList();
});

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get(ApiEndpoints.adminStats);
  return response.data['data'];
});

final slotsProvider = FutureProvider.family<List<TimeSlot>, ({String officeId, String date})>((ref, params) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('${ApiEndpoints.offices}/${params.officeId}/slots?date=${params.date}');
  return (response.data['data'] as List).map((e) => TimeSlot.fromJson(e)).toList();
});

import '../providers/citizen_provider.dart';

class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio dio;
  final Ref ref;

  BookingNotifier(this.dio, this.ref) : super(const AsyncValue.data(null));

  Future<bool> createBooking({
    required String officeId,
    required String serviceId,
    required String date,
    required String timeSlotId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await dio.post(ApiEndpoints.bookings, data: {
        'officeId': officeId,
        'serviceId': serviceId,
        'date': date,
        'timeSlotId': timeSlotId,
      });
      
      // Invalidate the bookings list so it refreshes immediately
      ref.invalidate(myBookingsProvider);
      
      state = const AsyncValue.data(null);
      return true;
    } on DioException catch (e) {
      state = AsyncValue.error(e.response?.data['message'] ?? 'Booking failed', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> cancelBooking(String id) async {
    try {
      await dio.patch('${ApiEndpoints.bookings}/$id/cancel');
      ref.invalidate(myBookingsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final bookingActionProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  return BookingNotifier(ref.watch(dioClientProvider).dio, ref);
});

